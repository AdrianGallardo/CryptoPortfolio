//
//  AddAssetsViewController.swift
//  CryptoPortfolio
//
//  Created by Adrian Gallardo on 28/06/21.
//

import Foundation
import UIKit

class AddAssetsViewController: UIViewController {
	@IBOutlet weak var searchBar: UISearchBar!
	@IBOutlet weak var tableView: UITableView!

	var listings: [CoinData] = []
	var searchToken: [CoinData] = []
	var dataController: DataController!

// MARK: - Lifecycle
	override func viewDidLoad() {
		super.viewDidLoad()

		tableView.rowHeight = 81
		searchBar.searchTextField.leftView?.tintColor = UIColor(red: 199, green: 197, blue: 197, alpha: 1.0)
	}

	override func viewWillAppear(_ animated: Bool) {
		self.navigationController?.isNavigationBarHidden = false
	}
}

// MARK: - UISearchBar Delegate
extension AddAssetsViewController: UISearchBarDelegate {
	func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
		searchToken = listings.filter({$0.name.prefix(searchText.count).lowercased() == searchText.lowercased() || $0.symbol.prefix(searchText.count).lowercased() == searchText.lowercased()})
		tableView.reloadData()
	}
}

// MARK: - UITableView Delegate
extension AddAssetsViewController: UITableViewDataSource, UITableViewDelegate {
	func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}

	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		if !searchToken.isEmpty {
//			print("search number of rows: \(searchToken.count)")
			return searchToken.count
		} else {
//			print("number of rows: \(listings.count)")
			return listings.count
		}
	}

	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "tokenViewCell") as! TokenViewCell
		var token: CoinData

		if !searchToken.isEmpty {
//			print("search token \(indexPath.row)")
			token = searchToken[indexPath.row]
		} else {
//			print("token \(indexPath.row)")
			token = listings[indexPath.row]
		}

		cell.setToken(token: token)
		return cell
	}

	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if let newAssetVC = segue.destination as? NewAssetViewController {
			if let indexPath = tableView.indexPathForSelectedRow {
				newAssetVC.dataController = dataController

				var token: CoinData!
				if !searchToken.isEmpty {
					token = searchToken[indexPath.row]
				} else {
					token = listings[indexPath.row]
				}

				newAssetVC.token = token
			}
		}
	}
}

// MARK: - TokenViewCell
class TokenViewCell: UITableViewCell {
	@IBOutlet weak var titleLabel: UILabel!
//	@IBOutlet weak var logoImageView: UIImageView!

	override func awakeFromNib() {
		super.awakeFromNib()
		let colors = [UIColor(red: 0.25, green: 0.26, blue: 0.27, alpha: 1.00).cgColor,
									UIColor(red: 0.14, green: 0.15, blue: 0.15, alpha: 1.00).cgColor]
		self.contentView.addGradientBackground(colors: colors, type: CAGradientLayerType.radial)
	}

	func setToken(token: CoinData) {
//		print("setToken")

// Enables Logo display in the table rows. Consumes API credits.
//		Client.getMetadata(id: token.id) { metadata, error in
//			guard let metadata = metadata else {
//				print("setToken error")
//				return
//			}
//			guard let urlLogo = URL(string: metadata.logo) else {
//				print("urlLogo error")
//				return
//			}
//
//			Client.downloadLogo(url: urlLogo) { data, error in
//				guard let data = data else {
//					print("dataLogo error")
//					return
//				}
//				self.logoImageView.image = UIImage(data: data)
//			}
//		}

		titleLabel.text = "[\(token.symbol)] - \(token.name)"
	}
}
