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
		updateTotalProfits()

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
		formatter.maximumFractionDigits = 2
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
	}

	func updateTotalProfits() {
		let feechRequest: NSFetchRequest<Asset> = Asset.fetchRequest()
		if let result = try? dataController.viewContext.fetch(feechRequest) {
			let assets = result
			var total: Double = 0
			for asset in assets {
				total = total + asset.total
			}

			self.totalFiatLabel.text = "$ " + formattedValue(total, decimals: 2)
		}
	}
}

// MARK: - TableView DataSource
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

		Client.getQuotes(id: Int(asset.id)) { quotesData, error in
			guard let quotesData = quotesData else {
				print("setAsset quotesData error")
				return
			}

			self.logoImageView.image = UIImage(data: logoData)
			self.symbolLabel.text = asset.symbol
			self.totalLabel.text = self.formattedValue(asset.total, decimals: 2) + " " + asset.symbol!
			self.priceLabel.text = "$ " + self.formattedValue(quotesData.quote["USD"]!.price, decimals: 2)
			self.percentchangeLabel.text = self.formattedValue(quotesData.quote["USD"]!.percent_change_24h, decimals: 2, pSign: true) + "%"

			if self.percentchangeLabel.text!.starts(with: "+") {
				self.percentchangeLabel.textColor = UIColor(red: 0.22, green: 0.94, blue: 0.49, alpha: 1.00)
			} else if self.percentchangeLabel.text!.starts(with: "-"){
				self.percentchangeLabel.textColor = UIColor(red: 1.00, green: 0.25, blue: 0.42, alpha: 1.00)
			}
		}
	}

	fileprivate func formattedValue(_ value :Double, decimals: Int, pSign: Bool = false) -> String{
		let formatter = NumberFormatter()
		formatter.numberStyle = .decimal
		formatter.maximumFractionDigits = 2
		if pSign {
			formatter.positivePrefix = "+"
		}
		return formatter.string(from: NSNumber(value: value))!
	}
}


