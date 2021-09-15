//
//  CurrencyFiatSettings.swift
//  CryptoPortfolio
//
//  Created by Adrian Gallardo on 05/09/21.
//

import Foundation
import UIKit

class CurrencySettingsViewController: UIViewController {
	@IBOutlet weak var tableView: UITableView!
	var lastSelection: IndexPath!
	var fiatCurrencyUserDefault: String?

	var fiatCurrencies: [FiatMapResponse] = []
	let usd = FiatMapResponse(id: 2781, name: "United States Dollar", sign: "$", symbol: "USD")
	let aud = FiatMapResponse(id: 2782, name: "Australian Dollar", sign: "$", symbol: "AUD")
	let cad = FiatMapResponse(id: 2784, name: "Canadian Dollar", sign: "$", symbol: "CAD")
	let eur = FiatMapResponse(id: 2790, name: "Euro", sign: "€", symbol: "EUR")
	let mxn = FiatMapResponse(id: 2799, name: "Mexican Peso", sign: "$", symbol: "MXN")

	override func viewDidLoad() {
		super.viewDidLoad()

		fiatCurrencies.append(usd)
		fiatCurrencies.append(aud)
		fiatCurrencies.append(cad)
		fiatCurrencies.append(eur)
		fiatCurrencies.append(mxn)

		tableView.reloadData()
	}
}

extension CurrencySettingsViewController: UITableViewDataSource, UITableViewDelegate {
	func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}

	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return fiatCurrencies.count
	}

	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let fiatCurrency = fiatCurrencies[indexPath.row]

		// Configure cell
		let cell = tableView.dequeueReusableCell(withIdentifier: "fiatViewCell") as! FiatViewCell
		cell.setFiatCurrency(fiatCurrency: fiatCurrency, accesory: false)

		return cell
	}

	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		if self.lastSelection != nil {
			self.tableView.cellForRow(at: self.lastSelection)?.accessoryType = .none
		}
		self.tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
		self.lastSelection = indexPath
		self.tableView.deselectRow(at: indexPath, animated: true)
	}
}

class FiatViewCell: UITableViewCell {
	func setFiatCurrency(fiatCurrency: FiatMapResponse, accesory: Bool) {
		textLabel?.text = fiatCurrency.name
		detailTextLabel?.text = fiatCurrency.symbol

		if accesory {
			accessoryType = .checkmark
		} else {
			accessoryType = .none
		}
	}
}
