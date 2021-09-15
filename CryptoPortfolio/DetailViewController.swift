//
//  DetailViewController.swift
//  CryptoPortfolio
//
//  Created by Adrian Gallardo on 23/08/21.
//

import Foundation
import UIKit

class DetailViewController: UIViewController {
	@IBOutlet weak var headerView: UIView!
	@IBOutlet weak var logoImageView: UIImageView!
	@IBOutlet weak var nameLabel: UILabel!
	@IBOutlet weak var rankLabel: UILabel!
	@IBOutlet weak var linkButton: UIButton!
	@IBOutlet weak var priceLabel: UILabel!
	@IBOutlet weak var percentLabel: UILabel!
	@IBOutlet weak var marketCapLabel: UILabel!
	@IBOutlet weak var circulatingSupplyLabel: UILabel!
	@IBOutlet weak var totalSupplyLabel: UILabel!
	@IBOutlet weak var maxSupplyLabel: UILabel!
	@IBOutlet weak var infoLabel: UILabel!

	let colorsMidnight = [UIColor(red: 0.25, green: 0.26, blue: 0.27, alpha: 1.00).cgColor,
												UIColor(red: 0.14, green: 0.15, blue: 0.15, alpha: 1.00).cgColor]

	var token: CoinData!
	var fiatSign: String?
	var fiatId: Int?

	override func viewDidLoad() {
		super.viewDidLoad()

		headerView.addGradientBackground(colors: colorsMidnight, type: CAGradientLayerType.axial)
		infoLabel.sizeToFit()

		fiatId = UserDefaults.standard.object(forKey: "idFiatCurrency") as? Int
		fiatSign = UserDefaults.standard.object(forKey: "signFiatCurrency") as? String

		Client.getQuotes(id: token.id, convert: fiatId!) { quotesData, error in
			guard let quotesData = quotesData else {
				print("DetailVC getQuotes error")
				return
			}
			let quotes = quotesData.quote[String(self.fiatId!)]!

			self.nameLabel.text = "\(quotesData.name) - (\(quotesData.symbol))"
			self.rankLabel.text = "Rank #\(String(quotesData.cmc_rank))"

			self.priceLabel.text = (self.fiatSign ?? "$ ") + self.formattedValue(quotes.price, decimals: 4)

			self.percentLabel.text = self.formattedValue(quotes.percent_change_24h, decimals: 2) + "%"
			if self.percentLabel.text!.starts(with: "-") {
				self.percentLabel.textColor = UIColor(red: 1.00, green: 0.25, blue: 0.42, alpha: 1.00)
			} else if self.percentLabel.text! == "0" {
				self.percentLabel.textColor = UIColor.white
			} else {
				self.percentLabel.textColor = UIColor(red: 0.22, green: 0.94, blue: 0.49, alpha: 1.00)
			}

			self.marketCapLabel.text = (self.fiatSign ?? "$ ") + self.formattedValue(quotes.market_cap, decimals: 2)

			if let circulatingSupply = quotesData.circulating_supply {
				self.circulatingSupplyLabel.text = self.formattedValue(Double(circulatingSupply), decimals: 2)
			} else {
				self.circulatingSupplyLabel.text = "-"
			}

			if let totalSupply = quotesData.total_supply {
				self.totalSupplyLabel.text = self.formattedValue(Double(totalSupply), decimals: 2)
			} else {
				self.totalSupplyLabel.text = "-"
			}

			if let maxSupply = quotesData.max_supply {
				self.maxSupplyLabel.text = self.formattedValue(Double(maxSupply), decimals: 2)
			} else {
				self.maxSupplyLabel.text = "-"
			}

			Client.getMetadata(id: self.token.id) { metadata, error in
				guard let metadata = metadata else {
					print("DetailVC metadata error")
					return
				}
				guard let urlLogo = URL(string: metadata.logo) else {
					print("DetailVC urlLogo error")
					return
				}

				if metadata.urls.website.count > 0 {
					self.linkButton.setTitle(metadata.urls.website[0], for: .normal)
				}
				self.infoLabel.text = "Description\n" + (metadata.description ?? "-")

				Client.downloadLogo(url: urlLogo) { data, error in
					guard let data = data else {
						print("DetailVC dataLogo error")
						return
					}
					self.logoImageView.image = UIImage(data: data)
				}
			}
		}
	}

	override func viewWillAppear(_ animated: Bool) {
		self.navigationController?.isNavigationBarHidden = false
	}

	@IBAction func linkButtonPressed(_ sender: Any) {
		if let url = URL(string: linkButton.titleLabel!.text!) {
			UIApplication.shared.open(url)
		}
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
