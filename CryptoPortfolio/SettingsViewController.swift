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
		print("viewDidLoad")
		if let timeFrame = UserDefaults.standard.object(forKey: "timeFrame") as? String {
			print("timeFrame: " + timeFrame)
			self.timeFrameLabel.text = timeFrame
		}
	}
}
