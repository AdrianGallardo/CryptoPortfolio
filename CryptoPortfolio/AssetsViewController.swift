//
//  ViewController.swift
//  CryptoPortfolio
//
//  Created by Adrian Gallardo on 22/04/21.
//

import UIKit
import CoreData

struct FakeAsset {
	var logo: String
	var symbol: String
	var id: Int
	var total: Double
	var price: Double
	var priceChange: Double
}

class AssetsViewController: UIViewController {

	var listings: [CoinData] = []
	var dataController: DataController!

	var fakeAssets: [FakeAsset] = [FakeAsset(logo: "btc", symbol: "BTC", id: 1, total: 99999999.9999, price: 9999999.99, priceChange: 1000),
																 FakeAsset(logo: "eth", symbol: "ETH", id: 1027, total: 99999999.9999, price: 9999999.99, priceChange: -1000),
																 FakeAsset(logo: "tether", symbol: "USDT", id: 825, total: 99999999.9999, price: 9999999.99, priceChange: 1000),
																 FakeAsset(logo: "bnb", symbol: "BNB", id: 1839, total: 99999999.9999, price: 9999999.99, priceChange: -1000),
																 FakeAsset(logo: "ada", symbol: "ADA", id: 2010, total: 99999999.9999, price: 9999999.99, priceChange: 1000)]

	@IBOutlet weak var totalLabel: UILabel!
	@IBOutlet weak var profitsLabel: UILabel!
	@IBOutlet weak var assetsOverviewView: UIView!
	@IBOutlet weak var assetsTableView: UITableView!

	override func viewDidLoad() {
		super.viewDidLoad()
		//Do any additional setup after loading the view
		assetsTableView.rowHeight = 107;
		setupListings()
		updateTotal()
		updateProfits()
	}

	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.identifier == "addToken" {
			let addVC = segue.destination as! AddAssetsViewController
			addVC.listings = self.listings
		}
	}

	fileprivate func setupListings() {
		Client.requestListings(convert: "USD") { listings, error in
			guard let listings = listings else{
				print("setupListings error")
				return
			}
			self.listings = listings

			//			print(listings.count)
			//			if listings.count > 0 {
			//				print(listings[0].id)
			//				print(listings[0].name)
			//				print(listings[0].symbol)
			//				print(String(reflecting: listings[0].quote["USD"]?.price))
			//				print(String(reflecting: listings[0].quote["USD"]?.percent_change_1h))
			//				print(String(reflecting: listings[0].quote["USD"]?.percent_change_24h))
			//				print(String(reflecting: listings[0].quote["MXN"]?.price))
			//			}
		}
	}

	func updateTotal() {

	}

	func updateProfits() {

	}
}

extension AssetsViewController: UITableViewDataSource, UITableViewDelegate {
	func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}

	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return fakeAssets.count
	}

	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "assetViewCell") as! AssetViewCell

		let asset = fakeAssets[indexPath.row]
		cell.setFakeAsset(fakeAsset: asset)

		return cell
	}

	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

	}
}

class AssetViewCell: UITableViewCell {
	@IBOutlet weak var logoImageView: UIImageView!
	@IBOutlet weak var symbolLabel: UILabel!
	@IBOutlet weak var priceLabel: UILabel!
	@IBOutlet weak var totalLabel: UILabel!
	@IBOutlet weak var percentchangeLabel: UILabel!


	func setAsset(asset: Asset) {
		guard let logoData = asset.logo else {
			return
		}
		self.logoImageView.image = UIImage(data: logoData)
		self.symbolLabel.text = asset.symbol
		self.totalLabel.text = String(asset.total)
	}

	func setFakeAsset(fakeAsset: FakeAsset) {
		print(String(reflecting: fakeAsset))
//		self.logoImageView.image = nil
		self.symbolLabel.text = fakeAsset.symbol
		self.priceLabel.text = "$" + String(fakeAsset.price)
		self.totalLabel.text = String(fakeAsset.total) + "BTC"
		self.percentchangeLabel.text = fakeAsset.priceChange > 0 ? "+" + String(fakeAsset.priceChange) + "%" : String(fakeAsset.priceChange) + "%"
	}
}



