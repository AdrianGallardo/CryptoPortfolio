//
//  MetadataResponse.swift
//  CryptoPortfolio
//
//  Created by Adrian Gallardo on 12/07/21.
//

import Foundation

struct Metadata: Codable {
	let id: Int
	let name: String
	let symbol: String
	let category: String
	let description: String
	let logo: String
}

struct MetadataResponse: Codable {
	let data: [Int: Metadata]
}
