//
//  EditAssetViewController.swift
//  CryptoPortfolio
//
//  Created by Adrian Gallardo on 19/08/21.
//

import Foundation
import UIKit
import CoreData

class EditAssetViewController: UIViewController {
	@IBOutlet weak var totalCryptoLabel: UILabel!
	@IBOutlet weak var totalFiatLabel: UILabel!
	@IBOutlet weak var cryptoTextField: UITextField!
	@IBOutlet weak var fiatTextField: UITextField!
	@IBOutlet weak var cryptoLogoImageView: UIImageView!
	@IBOutlet weak var fiatSymbolLabel: UILabel!
	@IBOutlet weak var addButton: UIButton!
	@IBOutlet weak var totalOverViewView: UIView!

	var asset: Asset!
	var dataController: DataController!
	var fiatSign: String?
	var fiatId: Int?

	let colorsMidnight = [UIColor(red: 0.25, green: 0.26, blue: 0.27, alpha: 1.00).cgColor,
												UIColor(red: 0.14, green: 0.15, blue: 0.15, alpha: 1.00).cgColor]

	// MARK: - Lifecycle
	override func viewDidLoad() {
		super.viewDidLoad()

		navigationController?.navigationBar.barTintColor = UIColor(red: 0.14, green: 0.15, blue: 0.15, alpha: 1.00)
		navigationController?.navigationBar.tintColor = UIColor.white

		cryptoTextField.layer.cornerRadius = 10.0
		cryptoTextField.clipsToBounds = true

		fiatTextField.layer.cornerRadius = 10.0
		fiatTextField.clipsToBounds = true
		
		fiatId = UserDefaults.standard.object(forKey: "idFiatCurrency") as? Int
		fiatSign = UserDefaults.standard.object(forKey: "signFiatCurrency") as? String

		self.fiatSymbolLabel.text = fiatSign

		self.cryptoTextField.text = String(format: "%.4f", asset.total)
		self.fiatTextField.text = String(format: "%.4f", asset.val)
		self.totalCryptoLabel.text = formattedValue(asset.total, decimals: 4) + " " + asset.symbol!
		self.totalFiatLabel.text = (self.fiatSign ?? "$") + formattedValue(asset.val, decimals: 2)
		self.cryptoLogoImageView.image = UIImage(data: asset.logo!)

		cryptoTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
		fiatTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
	}

	override func viewWillAppear(_ animated: Bool) {
		fiatId = UserDefaults.standard.object(forKey: "idFiatCurrency") as? Int
		fiatSign = UserDefaults.standard.object(forKey: "signFiatCurrency") as? String
		self.navigationController?.isNavigationBarHidden = false
	}

	// MARK: - Actions
	@IBAction func add(_ sender: Any) {
		guard Double(cryptoTextField.text!) != nil else{
			let alert = UIAlertController(title: "Edit Asset", message: "\nEnter the Total Crypto amount\n", preferredStyle: .alert)
			alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
			self.present(alert, animated: true)
			return
		}

		guard Double(cryptoTextField.text!)! > 0 else{
			let alert = UIAlertController(title: "Edit Asset", message: "\nThe Total Crypto amount can't be 0\n", preferredStyle: .alert)
			alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
			self.present(alert, animated: true)
			return
		}

		let alert = UIAlertController(title: "Edit Asset", message: "\nAdd \(cryptoTextField.text ?? "0") " + self.asset.symbol! + " Tokens to your assets?\n", preferredStyle: .alert)

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
			fiatTextField.text = String(format: "%.2f", Double(val)! * asset.price)
			break
		case fiatTextField:
			cryptoTextField.text = String(format: "%.4f", Double(val)! / asset.price)
			break
		default:
			break
		}

		totalCryptoLabel.text = cryptoTextField.text! + " " + asset.symbol!
		totalFiatLabel.text = (self.fiatSign ?? "$") + fiatTextField.text!
	}

	func save() {
		let fetchRequest: NSFetchRequest<Asset> = Asset.fetchRequest()
		fetchRequest.predicate = NSPredicate(format: "id == %@", String(asset.id))

		if let result = try? dataController.viewContext.fetch(fetchRequest), result.count > 0 {
			result[0].setValue(Double(cryptoTextField.text!)!, forKey: "total")
			result[0].setValue(Double(fiatTextField.text!)!, forKey: "val")
		}

		if self.dataController.viewContext.hasChanges {
//			print("saving asset")
			do {
				try self.dataController.viewContext.save()
//				print("asset saved")
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
