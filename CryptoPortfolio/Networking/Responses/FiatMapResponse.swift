//
//  FiatMapResponse.swift
//  CryptoPortfolio
//
//  Created by Adrian Gallardo on 05/09/21.
//

import Foundation

struct FiatMapResponse: Codable {
	let id: Int
	let name: String
	let sign: String
	let symbol: String
}
