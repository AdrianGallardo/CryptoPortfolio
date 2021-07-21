//
//  ListingsResponse.swift
//  CryptoPortfolio
//
//  Created by Adrian Gallardo on 17/05/21.
//

import Foundation

struct Quote: Codable {
	let price: Double
	let percent_change_1h: Double
	let percent_change_24h: Double
}

struct CoinData: Codable {
	let id: Int
	let name: String
	let symbol: String
	let quote: [String: Quote]
}

struct ListingsResponse: Codable {
	let data: [CoinData]
}
