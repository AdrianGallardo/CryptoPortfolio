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

	let colorsMidnight = [UIColor(red: 0.25, green: 0.26, blue: 0.27, alpha: 1.00).cgColor,
												UIColor(red: 0.14, green: 0.15, blue: 0.15, alpha: 1.00).cgColor]

	// MARK: - Lifecycle
	override func viewDidLoad() {
		super.viewDidLoad()
		totalOverViewView.addGradientBackground(colors: colorsMidnight, type: CAGradientLayerType.axial)

		self.cryptoTextField.text = "\(asset.total)"
		self.fiatTextField.text = String(format: "%.4f", asset.val)
		self.totalCryptoLabel.text = String(format: "%.4f", asset.total) + " " + asset.symbol!
		self.totalFiatLabel.text = "$ " + String(format: "%.4f", asset.val)
		self.cryptoLogoImageView.image = UIImage(data: asset.logo!)

		cryptoTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
		fiatTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
	}

	override func viewWillAppear(_ animated: Bool) {
		self.navigationController?.isNavigationBarHidden = false
	}

	// MARK: - Auxiliar Functions
	@objc func textFieldDidChange(_ textField: UITextField) {
		guard let val = textField.text, !val.isEmpty else {
			return
		}

		switch textField {
		case cryptoTextField:
			fiatTextField.text = String(format: "%.4f", Double(val)! * asset.price)
			break
		case fiatTextField:
			cryptoTextField.text = String(format: "%.4f", Double(val)! / asset.price)
			break
		default:
			break
		}

		totalCryptoLabel.text = cryptoTextField.text! + " " + asset.symbol!
		totalFiatLabel.text = "$" + " " + fiatTextField.text!
	}

	@IBAction func add(_ sender: Any) {
		let alert = UIAlertController(title: "Edit Asset", message: "\nAdd \(cryptoTextField.text ?? "0") " + self.asset.symbol! + " Tokens to your assets?\n", preferredStyle: .alert)

		alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { action in
			self.save()
		}))
		alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))

		self.present(alert, animated: true)
	}

	func save() {
		let fetchRequest: NSFetchRequest<Asset> = Asset.fetchRequest()
		fetchRequest.predicate = NSPredicate(format: "id == %@", String(asset.id))

		if let result = try? dataController.viewContext.fetch(fetchRequest), result.count > 0 {
			let total = Double(cryptoTextField.text!)!
			result[0].setValue(total, forKey: "total")
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
}