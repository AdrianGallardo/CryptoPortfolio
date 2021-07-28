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

	override func viewDidLoad() {
		super.viewDidLoad()
		print("NewAssetVC getLogo")

		Client.getMetadata(id: token.id) { metadata, error in
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
			}
		}

	}
}
