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
		super.viewDidLoad()
		idFiatCurrencyUserDefault = UserDefaults.standard.object(forKey: "idFiatCurrency") as? Int
		navigationController?.navigationBar.barTintColor = UIColor(red: 0.14, green: 0.15, blue: 0.15, alpha: 1.00)
		navigationController?.navigationBar.tintColor = UIColor.white
	}

	override func viewWillAppear(_ animated: Bool) {
		self.navigationController?.isNavigationBarHidden = false
	}

	override var preferredStatusBarStyle: UIStatusBarStyle {
		return .lightContent
	}
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

	func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
		(view as! UITableViewHeaderFooterView).contentView.backgroundColor = UIColor(red: 0.14, green: 0.15, blue: 0.15, alpha: 1.00)
		(view as! UITableViewHeaderFooterView).textLabel?.textColor = UIColor.white
	}

	func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
		cell.contentView.superview?.backgroundColor = UIColor(red: 0.19, green: 0.20, blue: 0.21, alpha: 1.00)
		cell.tintColor = UIColor.white
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
