//
//  NewAssetViewController.swift
//  CryptoPortfolio
//
//  Created by Adrian Gallardo on 13/07/21.
//

import Foundation
import UIKit

class NewAssetViewController: UIViewController {
	@IBOutlet weak var totalCryptoLabel: UILabel!
	@IBOutlet weak var totalFiatLabel: UILabel!
	@IBOutlet weak var cryptoTextBox: UITextField!
	@IBOutlet weak var fiatTextBox: UITextField!
	@IBOutlet weak var cryptoLogoImageView: UIImageView!
	@IBOutlet weak var fiatSymbolLabel: UILabel!
	@IBOutlet weak var addButton: UIButton!

	var token: CoinData!
	var dataController: DataController!
	var logoData: Data!
	var price: Double!

	override func viewDidLoad() {
		super.viewDidLoad()

		Client.getQuotes(id: token.id) { quotesData, error in
			guard let quotesData = quotesData else {
				print("NewAssetVC getQuotes error")
				return
			}
			self.price = quotesData.quote["USD"]!.price
			self.cryptoTextBox.text = "\(1)"
			self.fiatTextBox.text = String(format: "%.4f", self.price)
			self.totalCryptoLabel.text = "1 \(self.token.symbol)"
			self.totalFiatLabel.text = "$ " + String(format: "%.4f", self.price)

			Client.getMetadata(id: self.token.id) { metadata, error in
				guard let metadata = metadata else {
					print("setToken error")
					return
				}
				guard let urlLogo = URL(string: metadata.logo) else {
					print("urlLogo error")
					return
				}

				Client.downloadLogo(url: urlLogo) { data, error in
					guard let data = data else {
						print("dataLogo error")
						return
					}
					self.cryptoLogoImageView.image = UIImage(data: data)
					self.logoData = data
				}
			}
		}

		cryptoTextBox.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
		fiatTextBox.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
	}

	@objc func textFieldDidChange(_ textField: UITextField) {
		guard let val = textField.text, !val.isEmpty else {
			return
		}

		switch textField {
		case cryptoTextBox:
			fiatTextBox.text = String(format: "%.4f", Double(val)! * self.price)
			break
		case fiatTextBox:
			cryptoTextBox.text = String(format: "%.4f", Double(val)! / self.price)
			break
		default:
		break
		}

		totalCryptoLabel.text = cryptoTextBox.text! + " " + token.symbol
		totalFiatLabel.text = "$" + " " + fiatTextBox.text!
	}

	@IBAction func add(_ sender: Any) {
		let asset = Asset(context: self.dataController.viewContext)
		asset.id = Int32(token.id)
		asset.logo = logoData
		asset.symbol = token.symbol
		asset.total = Double(cryptoTextBox.text!)!

		if self.dataController.viewContext.hasChanges {
			print("saving asset")
			do {
				try self.dataController.viewContext.save()
				print("asset saved")
			} catch {
				print(error.localizedDescription)
			}
		}
	}
}
