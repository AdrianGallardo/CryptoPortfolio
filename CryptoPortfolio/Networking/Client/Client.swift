//
//  Client.swift
//  CryptoPortfolio
//
//  Created by Adrian Gallardo on 06/05/21.
//

import Foundation

class Client {
	static let apiKey = "0f049b45-e892-4284-aa68-b68edcecba5a"

	// MARK: - Auxiliar functions
	class func downloadLogo(url: URL, completion: @escaping (Data?, Error?) -> Void) {
		let imageTask = URLSession.shared.dataTask(with: url) { (data, response, error) in
			DispatchQueue.main.async {
				completion(data, error)
			}
		}

		imageTask.resume()
	}

	class func requestListings(convert: Int, completion: @escaping ([CoinData]?, Error?) -> Void) {
		guard let url = Endpoints.listingsLatest(convert).url else{
			print("requestListings URL error")
			return
		}

		taskForGETRequest(url: url, response: ListingsResponse.self) { response, error in
			if let response = response {
				completion(response.data, nil)
			} else {
				completion([], error)
			}
		}
	}

	class func requestFiatMap(completion: @escaping ([FiatData]?, Error?) -> Void) {
		guard let url = Endpoints.fiatMap.url else{
			print("requestFiatMap URL error")
			return
		}

		taskForGETRequest(url: url, response: FiatMapResponse.self) { response, error in
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

		taskForGETRequest(url: url, response: MetadataResponse.self) { response, error in
			if let response = response {
				completion(response.data[id], nil)
			} else {
				completion(nil, error)
			}
		}
	}

	class func getQuotes(id: Int, convert: Int, completion: @escaping (QuotesData?, Error?) -> Void) {
		guard let url = Endpoints.quotes(id, convert).url else {
			print("getQuotes URL error")
			return
		}

		taskForGETRequest(url: url, response: QuotesResponse.self) { response, error in
			if let response = response {
				completion(response.data[String(id)], nil)
			} else {
				completion(nil, error)
			}
		}
	}

	// MARK: - GET Task
	class func taskForGETRequest<ResponseType: Decodable>(url: URL?, response: ResponseType.Type, completion: @escaping (ResponseType?, Error?) -> Void) {

		guard let url = url else {
			return
		}

		var request = URLRequest(url: url)
		request.setValue(Endpoints.apiKey, forHTTPHeaderField: "X-CMC_PRO_API_KEY")
		let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
			guard let data = data else {
				DispatchQueue.main.async {
					completion(nil, error)
				}
				return
			}

			let decoder = JSONDecoder()
			do {
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
		static let baseFiat = "https://pro-api.coinmarketcap.com/v1/fiat/"
		static let apiKey = "0f049b45-e892-4284-aa68-b68edcecba5a"
		static let limit = 5000

		case getIdMap
		case listingsLatest(Int)
		case fiatMap
		case metadata(Int)
		case quotes(Int, Int)

		var stringValue: String {
			switch self {
			case .getIdMap: return Endpoints.base + "map"
			case .listingsLatest(let convertId): return Endpoints.base + "listings/latest?limit=\(Endpoints.limit)&convert_id=\(convertId)"
			case .fiatMap: return Endpoints.baseFiat + "map"
			case .metadata(let id): return Endpoints.base + "info?id=\(id)"
			case .quotes(let id, let convertId): return Endpoints.base + "quotes/latest?id=\(id)&convert_id=\(convertId)"
			}
		}

		var url: URL? {
			return URL(string: stringValue)
		}
	}
}
