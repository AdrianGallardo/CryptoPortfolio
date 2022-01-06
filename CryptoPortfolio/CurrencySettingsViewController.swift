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

	var fiatCurrencies: [FiatData] = []
	var lastSelection: IndexPath!
	var idFiatCurrencyUserDefault: Int?

	// MARK: - Lifecycle
	override func viewDidLoad() {
		print(" CurrencySettingsViewcontroller: viewDidLoad")
		super.viewDidLoad()
		idFiatCurrencyUserDefault = UserDefaults.standard.object(forKey: "idFiatCurrency") as? Int
	}

	override func viewWillAppear(_ animated: Bool) {
		print(" CurrencySettingsViewcontroller: viewWillAppear")
	}

//	// MARK: - Auxiliar Functions
//	fileprivate func configActivityView(animating: Bool) {
//		if animating {
//			self.activityIndicator.startAnimating()
//		} else {
//			self.activityIndicator.stopAnimating()
//		}
//		self.activityIndicator.isHidden = !animating
//		self.activityIndicatorView.isHidden = !animating
//	}
}

// MARK: - UITableViewDelegate
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
		cell.setFiatCurrency(fiatCurrency: fiatCurrency, accesory: (fiatCurrency.id == idFiatCurrencyUserDefault))

		if fiatCurrency.id == idFiatCurrencyUserDefault {
			lastSelection = indexPath
		}

		return cell
	}

	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		if self.lastSelection != nil {
			self.tableView.cellForRow(at: self.lastSelection)?.accessoryType = .none
		}
		self.tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
		self.lastSelection = indexPath
		self.tableView.deselectRow(at: indexPath, animated: true)

		UserDefaults.standard.set(self.fiatCurrencies[indexPath.row].id, forKey: "idFiatCurrency")
		UserDefaults.standard.set(self.fiatCurrencies[indexPath.row].sign, forKey: "signFiatCurrency")
		UserDefaults.standard.set(self.fiatCurrencies[indexPath.row].symbol, forKey: "symbolFiatCurrency")
	}
}

// MARK: - FiatViewCell
class FiatViewCell: UITableViewCell {
	func setFiatCurrency(fiatCurrency: FiatData, accesory: Bool) {
		textLabel?.text = fiatCurrency.name
		detailTextLabel?.text = fiatCurrency.symbol

		if accesory {
			accessoryType = .checkmark
		} else {
			accessoryType = .none
		}
	}
}
