//
//  SettingsViewController.swift
//  CryptoPortfolio
//
//  Created by Adrian Gallardo on 01/09/21.
//

import Foundation
import UIKit
import CoreData

class SettingsViewController: UITableViewController {
	@IBOutlet weak var fiatCurrencyLabel: UILabel!
	@IBOutlet weak var timeFrameLabel: UILabel!

	var dataController: DataController!

	// MARK: - Lifecycle
	override func viewDidLoad() {
		super.viewDidLoad()
	}

	override func viewWillAppear(_ animated: Bool) {
		if let fiatCurrency = UserDefaults.standard.object(forKey: "symbolFiatCurrency") as? String {
			self.fiatCurrencyLabel.text = fiatCurrency
		}
		if let timeFrame = UserDefaults.standard.object(forKey: "timeFrame") as? String {
			self.timeFrameLabel.text = timeFrame
		}
		self.navigationController?.isNavigationBarHidden = true
	}

	override var preferredStatusBarStyle: UIStatusBarStyle {
		return .lightContent
	}

	override func viewWillDisappear(_ animated: Bool) {
		let fiatId = UserDefaults.standard.object(forKey: "idFiatCurrency") as? Int
		let fetchRequest: NSFetchRequest<Asset> = Asset.fetchRequest()

		if let result = try? dataController.viewContext.fetch(fetchRequest), result.count > 0 {
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

					if self.dataController.viewContext.hasChanges {
						do {
							try self.dataController.viewContext.save()
						} catch {
							print(error.localizedDescription)
						}
					}
				}
			}
		}
	}

	override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
		(view as! UITableViewHeaderFooterView).contentView.backgroundColor = UIColor(red: 0.14, green: 0.15, blue: 0.15, alpha: 1.00)
		(view as! UITableViewHeaderFooterView).textLabel?.textColor = UIColor.white
	}

	override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
		cell.contentView.superview?.backgroundColor = UIColor(red: 0.19, green: 0.20, blue: 0.21, alpha: 1.00)
		cell.tintColor = UIColor.white
	}

	// MARK: - Auxiliar Functions
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if let currencySettingsVC = segue.destination as? CurrencySettingsViewController {
			currencySettingsVC.fiatCurrencies = self.dataController.fiatCurrencies
		}
	}
}
