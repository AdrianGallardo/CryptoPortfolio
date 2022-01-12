//
//  DataController.swift
//  CryptoPortfolio
//
//  Created by Adrian Gallardo on 29/06/21.
//

import Foundation
import CoreData

class DataController {
	let persistentContainer: NSPersistentContainer
	var fiatCurrencies: [FiatData] = []

	var viewContext: NSManagedObjectContext {
		return persistentContainer.viewContext
	}

	init(modelName: String) {
		persistentContainer = NSPersistentContainer(name: modelName)
	}

	func load(completion: (() -> Void)? = nil) {
//		print("Load")
		persistentContainer.loadPersistentStores { (storeDescription, error) in
			guard error == nil else {
				fatalError(error!.localizedDescription)
			}
			completion?()

			self.setupFiatCurrencies()
			self.updateQuotes()
		}
	}
	
	func updateQuotes(interval: TimeInterval = 60) {
		print("Update Quotes")
		guard interval > 0 else {
			print("interval must be a positive number")
			return
		}

		let fiatId = UserDefaults.standard.object(forKey: "idFiatCurrency") as? Int
		let fetchRequest: NSFetchRequest<Asset> = Asset.fetchRequest()

		if let result = try? viewContext.fetch(fetchRequest), result.count > 0 {
			for asset in result {
				Client.getQuotes(id: Int(asset.id), convert: fiatId!) { quotesData, error in
					guard let quotesData = quotesData else {
						print("updateQuotes getQuotes error")
						return
					}
					let quotes = quotesData.quote[String(fiatId!)]!

					asset.setValue(quotes.pChange1h, forKey: "pchange1h")
					asset.setValue(quotes.pChange7d, forKey: "pchange7d")
					asset.setValue(quotes.pChange24h, forKey: "pchange24h")
					asset.setValue(quotes.pChange30d, forKey: "pchange30d")
					asset.setValue(quotes.price, forKey: "price")
					asset.setValue(asset.total * quotes.price, forKey: "val")

					if self.viewContext.hasChanges {
						do {
							try self.viewContext.save()
						} catch {
							print(error.localizedDescription)
						}
					}
				}
			}
		}

		DispatchQueue.main.asyncAfter(deadline: .now() + interval) {
			self.updateQuotes(interval: interval)
		}
	}

	func setupFiatCurrencies() {
		Client.requestFiatMap() { fiatCurrencies, error in
			guard let fiatCurrencies = fiatCurrencies else{
				print("setupFiatCurrencies error")
				return
			}
			self.fiatCurrencies = fiatCurrencies
		}
	}
}

