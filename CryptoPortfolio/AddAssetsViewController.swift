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

	override func viewDidLoad() {
		super.viewDidLoad()
		tableView.rowHeight = 54
	}
}

extension AddAssetsViewController: UISearchBarDelegate {
	func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
		searchToken = listings.filter({$0.name.prefix(searchText.count) == searchText})
		tableView.reloadData()
	}
}

extension AddAssetsViewController: UITableViewDataSource, UITableViewDelegate {
	func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}

	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		if !searchToken.isEmpty {
			print("search number of rows: \(searchToken.count)")
			return searchToken.count
		} else {
			print("number of rows: \(listings.count)")
			return listings.count
		}
	}

	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "tokenViewCell") as! TokenViewCell
		var token: CoinData

		if !searchToken.isEmpty {
			print("search token \(indexPath.row)")
			token = searchToken[indexPath.row]
		} else {
			print("token \(indexPath.row)")
			token = listings[indexPath.row]
		}

		cell.setToken(token: token)
		return cell
	}

	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		// If this is a NoteDetailsViewController, we'll configure its `Note`
		// and its delete action
		if let newAssetVC = segue.destination as? NewAssetViewController {
			if let indexPath = tableView.indexPathForSelectedRow {
				newAssetVC.token = listings[indexPath.row]
				newAssetVC.dataController = dataController
			}
		}
	}

}

class TokenViewCell: UITableViewCell {
	@IBOutlet weak var titleLabel: UILabel!

	func setToken(token: CoinData) {
		print("setToken")
//		Client.getMetadata(id: token.id) { metadata, error in
//			guard let metadata = metadata else {
//				print("setToken error")
//				return
//			}
//			guard let urlLogo = URL(string: metadata.logo) else {
//				print("urlLogo error")
//				return
//			}

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
