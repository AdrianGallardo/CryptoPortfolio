//
//  ListingsResponse.swift
//  CryptoPortfolio
//
//  Created by Adrian Gallardo on 17/05/21.
//

import Foundation

struct CoinData: Codable {
	let id: Int
	let name: String
	let symbol: String
}

struct ListingsResponse: Codable {
	let data: [CoinData]
}
