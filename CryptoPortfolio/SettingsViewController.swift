//
//  SettingsViewController.swift
//  CryptoPortfolio
//
//  Created by Adrian Gallardo on 01/09/21.
//

import Foundation
import UIKit

class SettingsViewController: UITableViewController {
	@IBOutlet weak var fiatCurrencyLabel: UILabel!
	@IBOutlet weak var timeFrameLabel: UILabel!

	override func viewWillAppear(_ animated: Bool) {
		if let fiatCurrency = UserDefaults.standard.object(forKey: "symbolFiatCurrency") as? String {
			self.fiatCurrencyLabel.text = fiatCurrency
		}
		if let timeFrame = UserDefaults.standard.object(forKey: "timeFrame") as? String {
			self.timeFrameLabel.text = timeFrame
		}
	}
}
