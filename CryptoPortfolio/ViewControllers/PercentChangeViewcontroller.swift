//
//  CurrencyFiatSettings.swift
//  CryptoPortfolio
//
//  Created by Adrian Gallardo on 05/09/21.
//

import Foundation
import UIKit

class PercentChangeViewController: UIViewController {
	@IBOutlet weak var tableView: UITableView!

//	var fiatCurrencies: [FiatData] = []
//	var lastSelection: IndexPath!
//	var idFiatCurrencyUserDefault: Int?

	var lastSelection: IndexPath!
	var timeFrameUserDefault: String?
	var timeFrames: [String] = ["1h", "24h", "7d", "30d"]

	// MARK: - Lifecycle
	override func viewDidLoad() {
//		super.viewDidLoad()
//		idFiatCurrencyUserDefault = UserDefaults.standard.object(forKey: "idFiatCurrency") as? Int
//		navigationController?.navigationBar.barTintColor = UIColor(red: 0.14, green: 0.15, blue: 0.15, alpha: 1.00)
//		navigationController?.navigationBar.tintColor = UIColor.white

		super.viewDidLoad()
		timeFrameUserDefault = UserDefaults.standard.object(forKey: "timeFrame") as? String
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
extension PercentChangeViewController: UITableViewDataSource, UITableViewDelegate {
	func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}

	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//		print("fiatCurrencies.count: \(fiatCurrencies.count)")
//		return fiatCurrencies.count
		return timeFrames.count
	}

	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//		let fiatCurrency = fiatCurrencies[indexPath.row]
//
//		// Configure cell
//		let cell = tableView.dequeueReusableCell(withIdentifier: "timeViewCell") as! TimeViewCell
//		cell.setFiatCurrency(fiatCurrency: fiatCurrency, accesory: (fiatCurrency.id == idFiatCurrencyUserDefault))
//
//		if fiatCurrency.id == idFiatCurrencyUserDefault {
//			lastSelection = indexPath
//		}
//
//		return cell

		let timeFrame = timeFrames[indexPath.row]

		// Configure cell
		let cell = tableView.dequeueReusableCell(withIdentifier: "timeViewCell") as! TimeViewCell
		cell.setTimeFrame(timeFrame: timeFrame, accesory: (timeFrame == timeFrameUserDefault))

		if timeFrame == timeFrameUserDefault {
			lastSelection = indexPath
		}

		return cell
	}

	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//		if self.lastSelection != nil {
//			self.tableView.cellForRow(at: self.lastSelection)?.accessoryType = .none
//		}
//		self.tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
//		self.lastSelection = indexPath
//		self.tableView.deselectRow(at: indexPath, animated: true)
//
//		UserDefaults.standard.set(self.fiatCurrencies[indexPath.row].id, forKey: "idFiatCurrency")
//		UserDefaults.standard.set(self.fiatCurrencies[indexPath.row].sign, forKey: "signFiatCurrency")
//		UserDefaults.standard.set(self.fiatCurrencies[indexPath.row].symbol, forKey: "symbolFiatCurrency")

		if self.lastSelection != nil {
			self.tableView.cellForRow(at: self.lastSelection)?.accessoryType = .none
		}
		self.tableView.cellForRow(at: self.lastSelection)?.tintColor = UIColor.white
		self.tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
		self.lastSelection = indexPath
		self.tableView.deselectRow(at: indexPath, animated: true)
		UserDefaults.standard.set(self.tableView.cellForRow(at: indexPath)?.textLabel?.text, forKey: "timeFrame")
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
class TimeViewCell: UITableViewCell {
	func setTimeFrame(timeFrame: String, accesory: Bool) {
		textLabel?.text = timeFrame
		if accesory {
			accessoryType = .checkmark
		} else {
			accessoryType = .none
		}
	}
}

