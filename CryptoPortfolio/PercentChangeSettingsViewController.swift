//
//  PercentChangeSettingsViewController.swift
//  CryptoPortfolio
//
//  Created by Adrian Gallardo on 05/09/21.
//

import Foundation
import UIKit

class PercentChangeSettingsViewController: UIViewController {
	@IBOutlet weak var tableView: UITableView!
	var lastSelection: IndexPath!
	var timeFrameUserDefault: String?
	var timeFrames: [String] = ["1h", "24h", "7d", "30d"]

	override func viewDidLoad() {
		super.viewDidLoad()
		timeFrameUserDefault = UserDefaults.standard.object(forKey: "timeFrame") as? String
		tableView.reloadData()
	}
}

extension PercentChangeSettingsViewController: UITableViewDataSource, UITableViewDelegate {
	func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}

	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return timeFrames.count
	}

	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let timeFrame = timeFrames[indexPath.row]

		// Configure cell
		let cell = tableView.dequeueReusableCell(withIdentifier: "timeFrameViewCell") as! TimeFrameViewCell
		cell.setTimeFrame(timeFrame: timeFrame, accesory: (timeFrame == timeFrameUserDefault))

		if timeFrame == timeFrameUserDefault {
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
		UserDefaults.standard.set(self.tableView.cellForRow(at: indexPath)?.textLabel?.text, forKey: "timeFrame")
	}
}

class TimeFrameViewCell: UITableViewCell {
	func setTimeFrame(timeFrame: String, accesory: Bool) {
		textLabel?.text = timeFrame
		if accesory {
			accessoryType = .checkmark
		} else {
			accessoryType = .none
		}
	}
}
