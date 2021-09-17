//
//  NewAssetViewController.swift
//  CryptoPortfolio
//
//  Created by Adrian Gallardo on 13/07/21.
//

import Foundation
import UIKit
import CoreData

class NewAssetViewController: UIViewController {
	@IBOutlet weak var totalCryptoLabel: UILabel!
	@IBOutlet weak var totalFiatLabel: UILabel!
	@IBOutlet weak var cryptoTextField: UITextField!
	@IBOutlet weak var fiatTextField: UITextField!
	@IBOutlet weak var cryptoLogoImageView: UIImageView!
	@IBOutlet weak var fiatSymbolLabel: UILabel!
	@IBOutlet weak var addButton: UIButton!
	@IBOutlet weak var totalOverViewView: UIView!

	var token: CoinData!
	var dataController: DataController!

	var logoData: Data?
	var name: String?
	var price: Double?
	var pChange1h: Double?
	var pChange24h: Double?
	var pChange7d: Double?
	var pChange30d: Double?
	var fiatSign: String?
	var fiatId: Int?

	let colorsMidnight = [UIColor(red: 0.25, green: 0.26, blue: 0.27, alpha: 1.00).cgColor,
												UIColor(red: 0.14, green: 0.15, blue: 0.15, alpha: 1.00).cgColor]

	// MARK: - Lifecycle
	override func viewDidLoad() {
		super.viewDidLoad()

		cryptoTextField.layer.cornerRadius = 10.0
		cryptoTextField.clipsToBounds = true

		fiatTextField.layer.cornerRadius = 10.0
		fiatTextField.clipsToBounds = true

		totalOverViewView.addGradientBackground(colors: colorsMidnight, type: CAGradientLayerType.axial)

		fiatId = UserDefaults.standard.object(forKey: "idFiatCurrency") as? Int
		fiatSign = UserDefaults.standard.object(forKey: "signFiatCurrency") as? String

		Client.getQuotes(id: token.id, convert: fiatId!) { quotesData, error in
			guard let quotesData = quotesData else {
				print("NewAssetVC getQuotes error")
				return
			}
			let quotes = quotesData.quote[String(self.fiatId!)]!

			self.price = quotes.price
			self.pChange1h = quotes.percent_change_1h
			self.pChange24h = quotes.percent_change_24h
			self.pChange7d = quotes.percent_change_7d
			self.pChange30d = quotes.percent_change_30d

			self.cryptoTextField.text = "1"
			self.fiatTextField.text = String(format: "%.2f", self.price!)
			self.totalCryptoLabel.text = "1 \(self.token.symbol)"
			self.totalFiatLabel.text = (self.fiatSign ?? "$") + self.formattedValue(self.price!, decimals: 2)

			Client.getMetadata(id: self.token.id) { metadata, error in
				guard let metadata = metadata else {
					print("setToken error")
					return
				}
				guard let urlLogo = URL(string: metadata.logo) else {
					print("urlLogo error")
					return
				}

				self.name = metadata.name

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

		cryptoTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
		fiatTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
	}

	// MARK: - Actions

	override func viewWillAppear(_ animated: Bool) {
		fiatId = UserDefaults.standard.object(forKey: "idFiatCurrency") as? Int
		fiatSign = UserDefaults.standard.object(forKey: "signFiatCurrency") as? String
		self.navigationController?.isNavigationBarHidden = false
	}

	@IBAction func add(_ sender: Any) {
		let alert = UIAlertController(title: "New Asset", message: "\nAdd \(cryptoTextField.text ?? "0") \(self.token.symbol) Tokens to your assets?\n", preferredStyle: .alert)

		alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { action in
			self.save()
		}))
		alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))

		self.present(alert, animated: true)
	}

	// MARK: - Auxiliar Functions
	@objc func textFieldDidChange(_ textField: UITextField) {
		guard let val = textField.text, !val.isEmpty else {
			return
		}

		switch textField {
		case cryptoTextField:
			fiatTextField.text = String(format: "%.4f", Double(val)! * self.price!)
			break
		case fiatTextField:
			cryptoTextField.text = String(format: "%.4f", Double(val)! / self.price!)
			break
		default:
			break
		}

		totalCryptoLabel.text = cryptoTextField.text! + " " + token.symbol
		totalFiatLabel.text = (fiatSign ?? "$") + fiatTextField.text!
	}

	func save() {
		let fetchRequest: NSFetchRequest<Asset> = Asset.fetchRequest()
		fetchRequest.predicate = NSPredicate(format: "id == %@", String(token.id))

		if let result = try? dataController.viewContext.fetch(fetchRequest), result.count > 0 {
			let total = result[0].total + Double(cryptoTextField.text!)!

			result[0].setValue(self.pChange1h, forKey: "pchange1h")
			result[0].setValue(self.pChange7d, forKey: "pchange7d")
			result[0].setValue(self.pChange24h, forKey: "pchange24h")
			result[0].setValue(self.pChange30d, forKey: "pchange30d")
			result[0].setValue(self.price, forKey: "price")
			result[0].setValue(total, forKey: "total")
			result[0].setValue(total * self.price!, forKey: "val")
		} else {
			let asset = Asset(context: self.dataController.viewContext)
			asset.id = Int32(token.id)
			asset.logo = logoData
			asset.name = name
			asset.pchange1h = pChange1h!
			asset.pchange7d = pChange7d!
			asset.pchange24h = pChange24h!
			asset.pchange30d = pChange30d!
			asset.price = price!
			asset.symbol = token.symbol
			asset.total = Double(cryptoTextField.text!)!
			asset.val = Double(cryptoTextField.text!)! * price!
		}

		if self.dataController.viewContext.hasChanges {
			print("saving asset")
			do {
				try self.dataController.viewContext.save()
				print("asset saved")
			} catch {
				print(error.localizedDescription)
			}
		}

		navigationController?.popToRootViewController(animated: true)
	}

	fileprivate func formattedValue(_ value :Double, decimals: Int, pSign: Bool = false) -> String{
		let formatter = NumberFormatter()
		formatter.numberStyle = .decimal
		formatter.maximumFractionDigits = decimals
		if pSign {
			formatter.positivePrefix = "+"
		}
		return formatter.string(from: NSNumber(value: value))!
	}
}
