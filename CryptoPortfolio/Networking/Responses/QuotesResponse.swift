//
//  QuotesResponse.swift
//  CryptoPortfolio
//
//  Created by Adrian Gallardo on 10/08/21.
//

import Foundation

struct Quote: Codable {
	let price: Double
	let volume24h: Double
	let pChange1h: Double
	let pChange24h: Double
	let pChange7d: Double
	let pChange30d: Double
	let marketCap: Double

	enum CodingKeys: String, CodingKey {
		case price = "price"
		case volume24h = "volume_24h"
		case pChange1h = "percent_change_1h"
		case pChange24h = "percent_change_24h"
		case pChange7d = "percent_change_7d"
		case pChange30d = "percent_change_30d"
		case marketCap = "market_cap"
	}
}

struct QuotesData: Codable {
	let id: Int
	let name: String
	let symbol: String
	let maxSupply: Double?
	let circulatingSupply: Double?
	let totalSupply: Double?
	let cmcRank: Int
	let quote: [String: Quote]

	enum CodingKeys: String, CodingKey {
		case id = "id"
		case name = "name"
		case symbol = "symbol"
		case maxSupply = "max_supply"
		case circulatingSupply = "circulating_supply"
		case totalSupply = "total_supply"
		case cmcRank = "cmc_rank"
		case quote = "quote"
	}
}

struct QuotesResponse: Codable {
	let data: [String: QuotesData]
}
