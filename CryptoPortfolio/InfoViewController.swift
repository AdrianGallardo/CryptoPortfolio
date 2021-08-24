//
//  AddAssetsViewController.swift
//  CryptoPortfolio
//
//  Created by Adrian Gallardo on 28/06/21.
//

import Foundation
import UIKit

class InfoViewController: UIViewController {
	@IBOutlet weak var searchBar: UISearchBar!
	@IBOutlet weak var tableView: UITableView!

	var listings: [CoinData] = []
	var searchToken: [CoinData] = []
	var dataController: DataController!

	// MARK: - Lifecycle
	override func viewDidLoad() {
		super.viewDidLoad()

		self.navigationController?.isNavigationBarHidden = true
		tableView.rowHeight = 81
		searchBar.searchTextField.leftView?.tintColor = UIColor(red: 199, green: 197, blue: 197, alpha: 1.0)

		setupListings()
	}

	override func viewWillAppear(_ animated: Bool) {
		self.navigationController?.isNavigationBarHidden = false
	}

	fileprivate func setupListings() {
		Client.requestListings(convert: "USD") { listings, error in
			guard let listings = listings else{
				print("setupListings error")
				return
			}
			self.listings = listings
			self.tableView.reloadData()
		}
	}
}

// MARK: - UISearchBar Delegate
extension InfoViewController: UISearchBarDelegate {
	func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
		searchToken = listings.filter({$0.name.prefix(searchText.count).lowercased() == searchText.lowercased() || $0.symbol.prefix(searchText.count).lowercased() == searchText.lowercased()})
		tableView.reloadData()
	}
}

// MARK: - UITableView Delegate
extension InfoViewController: UITableViewDataSource, UITableViewDelegate {
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


