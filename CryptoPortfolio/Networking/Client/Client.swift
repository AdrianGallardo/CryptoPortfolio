//
//  Client.swift
//  CryptoPortfolio
//
//  Created by Adrian Gallardo on 06/05/21.
//

import Foundation

class Client {
	static let apiKey = "cce5ce72-fbb1-4dc6-899b-c8a0df1ae085"

	// MARK: - Auxiliar functions
	class func downloadLogo(url: URL, completion: @escaping (Data?, Error?) -> Void) {
		let imageTask = URLSession.shared.dataTask(with: url) { (data, response, error) in
			DispatchQueue.main.async {
				completion(data, error)
			}
		}

		imageTask.resume()
	}

	class func requestListings(convert: String, completion: @escaping ([CoinData]?, Error?) -> Void) {
		guard let url = Endpoints.listingsLatest(convert).url else{
			print("requestListings URL error")
			return
		}

		print("requestListings")
		taskForGETRequest(url: url, response: ListingsResponse.self) { response, error in
			if let response = response {
				completion(response.data, nil)
			} else {
				completion([], error)
			}
		}
	}

	class func getMetadata(id: Int, completion: @escaping (Metadata?, Error?) -> Void) {
		guard let url = Endpoints.metadata(id).url else {
			print("getMeta URL error")
			return
		}

		print("getMetadata")
		taskForGETRequest(url: url, response: MetadataResponse.self) { response, error in
			if let response = response {
				completion(response.data[id], nil)
			} else {
				completion(nil, error)
			}
		}
	}

	class func getQuotes(id: Int, completion: @escaping (QuotesData?, Error?) -> Void) {
		guard let url = Endpoints.quotes(id).url else {
			print("getQuotes URL error")
			return
		}

		print("getQuotes")
		taskForGETRequest(url: url, response: QuotesResponse.self) { response, error in
			if let response = response {
				completion(response.data[String(id)], nil)
			} else {
				completion(nil, error)
			}
		}
	}

	// MARK: - POST Task

	// MARK: - GET Task
	class func taskForGETRequest<ResponseType: Decodable>(url: URL?, response: ResponseType.Type, completion: @escaping (ResponseType?, Error?) -> Void) {

		print("taskForGETRequest")

		guard let url = url else {
			return
		}

		var request = URLRequest(url: url)
		request.setValue(Endpoints.apiKey, forHTTPHeaderField: "X-CMC_PRO_API_KEY")

//		print("taskForGETRequest: url -> " + String(reflecting: url))

		let task = URLSession.shared.dataTask(with: request) { (data, response, error) in

//			print("client taskForGETRequest: data -> " + String(data: data!, encoding: .utf8)!)

			guard let data = data else {
				DispatchQueue.main.async {
					completion(nil, error)
				}
				return
			}

			let decoder = JSONDecoder()
			do {
//				print("decode -> " + String(reflecting: data))
				let responseObject = try decoder.decode(ResponseType.self, from: data)
				DispatchQueue.main.async {
					completion(responseObject, nil)
				}
			} catch {
				print("client taskForGETRequest error: " +  error.localizedDescription)
				DispatchQueue.main.async {
					completion(nil, error)
				}
			}
		}
		task.resume()

	}


}
	// MARK: - Endpoints
extension Client{
	enum Endpoints {

		static let base = "https://pro-api.coinmarketcap.com/v1/cryptocurrency/"
		static let apiKey = "cce5ce72-fbb1-4dc6-899b-c8a0df1ae085"
//		static let limit = 5000
		static let limit = 100

		case getIdMap
		case listingsLatest(String)
		case metadata(Int)
		case quotes(Int)

		var stringValue: String {
			switch self {
			case .getIdMap: return Endpoints.base + "map"
			case .listingsLatest(let convert): return Endpoints.base + "listings/latest?limit=\(Endpoints.limit)&convert=\(convert)"
			case .metadata(let id): return Endpoints.base + "info?id=\(id)"
			case .quotes(let id): return Endpoints.base + "quotes/latest?id=\(id)"
			}
		}

		var url: URL? {
			return URL(string: stringValue)
		}
	}
}
