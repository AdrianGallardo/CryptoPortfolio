//
//  QuotesResponse.swift
//  CryptoPortfolio
//
//  Created by Adrian Gallardo on 10/08/21.
//

import Foundation

struct Quote: Codable {
	let price: Double
	let volume_24h: Double
	let percent_change_1h: Double
	let percent_change_24h: Double
	let percent_change_7d: Double
	let percent_change_30d: Double
	let market_cap: Double
}

struct QuotesData: Codable {
	let id: Int
	let name: String
	let symbol: String
	let quote: [String: Quote]
}

struct QuotesResponse: Codable {
	let data: [String: QuotesData]
}
