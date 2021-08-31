//
//  MetadataResponse.swift
//  CryptoPortfolio
//
//  Created by Adrian Gallardo on 12/07/21.
//

import Foundation

struct UrlsMetada: Codable {
	let website: [String]
}

struct Metadata: Codable {
	let id: Int
	let name: String
	let symbol: String
	let description: String?
	let logo: String
	let urls: UrlsMetada
}

struct MetadataResponse: Codable {
	let data: [Int: Metadata]
}
