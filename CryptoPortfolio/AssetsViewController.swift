//
//  ViewController.swift
//  CryptoPortfolio
//
//  Created by Adrian Gallardo on 22/04/21.
//

import UIKit
import CoreData

class AssetsViewController: UIViewController {

	var listings: [CoinData] = []
	var dataController: DataController!
	var fetchedResultsController: NSFetchedResultsController<Asset>!
	var saveObserverToken: Any?

	let colorsMidnight = [UIColor(red: 0.25, green: 0.26, blue: 0.27, alpha: 1.00).cgColor,
												UIColor(red: 0.14, green: 0.15, blue: 0.15, alpha: 1.00).cgColor]

	@IBOutlet weak var totalFiatLabel: UILabel!
	@IBOutlet weak var totalCryptoLabel: UILabel!
	@IBOutlet weak var assetsOverviewView: UIView!
	@IBOutlet weak var assetsTableView: UITableView!

//	MARK: - Lifecycle
	override func viewDidLoad() {
		super.viewDidLoad()

		//Do any additional setup after loading the view
		assetsTableView.rowHeight = 107;
		assetsOverviewView.addGradientBackground(colors: colorsMidnight, type: CAGradientLayerType.axial)

		addSaveNotificationObserver()
		setupListings()
	}

	override func viewWillAppear(_ animated: Bool) {
		setupFetchedResultsController()
		updateQuotes()

		self.navigationController?.isNavigationBarHidden = true
	}

	override func viewDidDisappear(_ animated: Bool) {
		super.viewDidDisappear(animated)
		fetchedResultsController = nil
	}

	deinit {
		removeSaveNotificationObserver()
	}

	fileprivate func setupFetchedResultsController() {
		let fetchRequest: NSFetchRequest<Asset> = Asset.fetchRequest()
		let sortDescriptor = NSSortDescriptor(key: "total", ascending: false)
    fetchRequest.sortDescriptors = [sortDescriptor]

		fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: nil)
		fetchedResultsController.delegate = self

		do {
			try fetchedResultsController.performFetch()
		} catch {
			fatalError("The fetch could not be performed: \(error.localizedDescription)")
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

// MARK: - Auxiliar Functions
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.identifier == "addToken" {
			let addVC = segue.destination as! AddAssetsViewController
			addVC.listings = self.listings
			addVC.dataController = self.dataController
		}
	}

	fileprivate func setupListings() {
		Client.requestListings(convert: "USD") { listings, error in
			guard let listings = listings else{
				print("setupListings error")
				return
			}
			self.listings = listings
		}
	}

	// Deletes the `Note` at the specified index path
	func deleteAsset(at indexPath: IndexPath) {
		let assetToDelete = fetchedResultsController.object(at: indexPath)
		dataController.viewContext.delete(assetToDelete)
		try? dataController.viewContext.save()
		updateQuotes()
	}

	func updateQuotes() {
		var newTotal: Double = 0
		self.totalFiatLabel.text = "$ 0"

		let fetchRequest: NSFetchRequest<Asset> = Asset.fetchRequest()

		if let result = try? dataController.viewContext.fetch(fetchRequest), result.count > 0 {
			for asset in result {
				Client.getQuotes(id: Int(asset.id)) { quotesData, error in
					guard let quotesData = quotesData else {
						print("NewAssetVC getQuotes error")
						return
					}
					let quotes = quotesData.quote["USD"]!

					asset.setValue(quotes.percent_change_1h, forKey: "pchange1h")
					asset.setValue(quotes.percent_change_7d, forKey: "pchange7d")
					asset.setValue(quotes.percent_change_24h, forKey: "pchange24h")
					asset.setValue(quotes.percent_change_30d, forKey: "pchange30d")
					asset.setValue(quotes.price, forKey: "price")
					asset.setValue(asset.total * quotes.price, forKey: "val")

					if self.dataController.viewContext.hasChanges {
						print("saving asset")
						do {
							try self.dataController.viewContext.save()
							print("asset saved")

							newTotal = newTotal + (quotes.price * asset.total)
							self.totalFiatLabel.text = "$ " + self.formattedValue(newTotal, decimals: 2)

						} catch {
							print(error.localizedDescription)
						}
					}
				}
			}
		}
	}

}

// MARK: - UITableView Delegate
extension AssetsViewController: UITableViewDataSource, UITableViewDelegate {
	func numberOfSections(in tableView: UITableView) -> Int {
		return fetchedResultsController.sections?.count ?? 1
	}

	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return fetchedResultsController.sections?[0].numberOfObjects ?? 0
	}

	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let asset = fetchedResultsController.object(at: indexPath)

		// Configure cell
		let cell = tableView.dequeueReusableCell(withIdentifier: "assetViewCell") as! AssetViewCell
		cell.setAsset(asset: asset)

		return cell
	}

	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let asset = fetchedResultsController.object(at: indexPath)

		let alert = UIAlertController(title: (asset.name ?? "Asset"), message: self.formattedValue(asset.total, decimals: 4) + " " + asset.symbol!, preferredStyle: .actionSheet)

		alert.addAction(UIAlertAction(title: "Edit", style: .default, handler: { action in
			if let editAssetVC = self.storyboard!.instantiateViewController(withIdentifier: "editAssetViewController") as? EditAssetViewController {
				editAssetVC.asset = asset
				editAssetVC.dataController = self.dataController

				self.navigationController!.pushViewController(editAssetVC, animated: true)
			}
		}))

		alert.addAction(UIAlertAction(title: "Info", style: .default, handler: { action in
			if let detailVC = self.storyboard!.instantiateViewController(withIdentifier: "detailViewController") as? DetailViewController {
//				editAssetVC.asset = asset
//				editAssetVC.dataController = self.dataController

				self.navigationController!.pushViewController(detailVC, animated: true)
			}
		}))

		alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { action in
			let deleteAlert = UIAlertController(title: "Are You sure?", message: "\nDelete " + self.formattedValue(asset.total, decimals: 4) + " " + asset.symbol! + " tokens\n", preferredStyle: .alert)

			deleteAlert.addAction(UIAlertAction(title: "Yes", style: .destructive, handler: { action in
				self.deleteAsset(at: indexPath)
			}))

			deleteAlert.addAction(UIAlertAction(title: "No", style: .default, handler: nil))

			self.present(deleteAlert, animated: true)
		}))

		alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

		self.present(alert, animated: true)
	}

	func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
		switch editingStyle {
		case .delete: deleteAsset(at: indexPath)
		default: () // Unsupported
		}
	}
}

// MARK: - NSFetchedResultsControllerDelegate
extension AssetsViewController: NSFetchedResultsControllerDelegate {

	func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
		switch type {
		case .insert:
			assetsTableView.insertRows(at: [newIndexPath!], with: .fade)
			break
		case .delete:
			assetsTableView.deleteRows(at: [indexPath!], with: .fade)
			break
		case .update:
			assetsTableView.reloadRows(at: [indexPath!], with: .fade)
		case .move:
			assetsTableView.moveRow(at: indexPath!, to: newIndexPath!)
		}
	}

	func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
		let indexSet = IndexSet(integer: sectionIndex)
		switch type {
		case .insert: assetsTableView.insertSections(indexSet, with: .fade)
		case .delete: assetsTableView.deleteSections(indexSet, with: .fade)
		case .update, .move:
			fatalError("Invalid change type in controller(_:didChange:atSectionIndex:for:). Only .insert or .delete should be possible.")
		}
	}

	func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
		assetsTableView.beginUpdates()
	}

	func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
		assetsTableView.endUpdates()
	}
}

// MARK: - Observe notifications
extension AssetsViewController {
	func addSaveNotificationObserver() {
		removeSaveNotificationObserver()
		saveObserverToken = NotificationCenter.default.addObserver(forName: .NSManagedObjectContextObjectsDidChange, object: dataController.viewContext, queue: nil, using: handleSaveNotification(notification:))
	}

	func removeSaveNotificationObserver() {
		if let token = saveObserverToken {
			NotificationCenter.default.removeObserver(token)
		}
	}

	fileprivate func reloadAssets() {
		assetsTableView.reloadData()
	}

	func handleSaveNotification(notification: Notification) {
		DispatchQueue.main.async {
			self.reloadAssets()
		}
	}
}

// MARK: - AssetViewCell
class AssetViewCell: UITableViewCell {
	@IBOutlet weak var logoImageView: UIImageView!
	@IBOutlet weak var symbolLabel: UILabel!
	@IBOutlet weak var priceLabel: UILabel!
	@IBOutlet weak var totalLabel: UILabel!
	@IBOutlet weak var percentchangeLabel: UILabel!

	let colorsMidnight = [UIColor(red: 0.25, green: 0.26, blue: 0.27, alpha: 1.00).cgColor,
												UIColor(red: 0.14, green: 0.15, blue: 0.15, alpha: 1.00).cgColor]

	override func awakeFromNib() {
		super.awakeFromNib()
		self.contentView.addGradientBackground(colors: colorsMidnight, type: CAGradientLayerType.radial)
	}

	func setAsset(asset: Asset) {
		guard let logoData = asset.logo else {
			return
		}

		self.logoImageView.image = UIImage(data: logoData)
		self.symbolLabel.text = asset.symbol
		self.totalLabel.text = self.formattedValue(asset.total, decimals: 4) + " " + asset.symbol!
		self.priceLabel.text = "$ " + self.formattedValue(asset.val, decimals: 2)
		self.percentchangeLabel.text = self.formattedValue(asset.pchange24h, decimals: 2, pSign: true) + "%"

		if self.percentchangeLabel.text!.starts(with: "+") {
			self.percentchangeLabel.textColor = UIColor(red: 0.22, green: 0.94, blue: 0.49, alpha: 1.00)
		} else if self.percentchangeLabel.text!.starts(with: "-"){
			self.percentchangeLabel.textColor = UIColor(red: 1.00, green: 0.25, blue: 0.42, alpha: 1.00)
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


