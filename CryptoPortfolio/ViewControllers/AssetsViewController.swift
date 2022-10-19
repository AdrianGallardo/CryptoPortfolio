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
	var fiatSign: String?
	var fiatId: Int?
	var timeFrame: String?

	let colorsMidnight = [UIColor(red: 0.25, green: 0.26, blue: 0.27, alpha: 1.00).cgColor,
												UIColor(red: 0.14, green: 0.15, blue: 0.15, alpha: 1.00).cgColor]
//	let usd = FiatData(id: 2781, name: "United States Dollar", sign: "$", symbol: "USD")

	@IBOutlet weak var totalFiatLabel: UILabel!
	@IBOutlet weak var totalCryptoLabel: UILabel!
	@IBOutlet weak var assetsOverviewView: UIView!
	@IBOutlet weak var assetsTableView: UITableView!
	@IBOutlet weak var activityIndicatorView: UIView!
	@IBOutlet weak var activityIndicator: UIActivityIndicatorView!

//	MARK: - Lifecycle
	override func viewDidLoad() {
		super.viewDidLoad()

		assetsTableView.rowHeight = 107;
		setupListings()
	}

	override func viewWillAppear(_ animated: Bool) {
		fiatId = UserDefaults.standard.object(forKey: "idFiatCurrency") as? Int
		fiatSign = UserDefaults.standard.object(forKey: "signFiatCurrency") as? String
		timeFrame = UserDefaults.standard.object(forKey: "timeFrame") as? String

		setupFetchedResultsController()
		addSaveNotificationObserver()
		self.totalCryptoLabel.text = UserDefaults.standard.object(forKey: "symbolFiatCurrency") as? String

		self.navigationController?.isNavigationBarHidden = true
		updateTotal()
		assetsTableView.reloadData()
	}

	override var preferredStatusBarStyle: UIStatusBarStyle {
		return .lightContent
	}

	override func viewDidDisappear(_ animated: Bool) {
		super.viewDidDisappear(animated)
		removeSaveNotificationObserver()
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
		configActivityView(animating: true)
		Client.requestListings(convert: UserDefaults.standard.object(forKey: "idFiatCurrency") as! Int) { listings, error in
			guard let listings = listings else {
				return
			}
			self.listings = listings
			self.configActivityView(animating: false)
		}
	}

	func deleteAsset(at indexPath: IndexPath) {
		let assetToDelete = fetchedResultsController.object(at: indexPath)
		dataController.viewContext.delete(assetToDelete)
		try? dataController.viewContext.save()
		updateTotal()
	}

	func updateTotal() {
		var total: Double = 0
		let fetchRequest: NSFetchRequest<Asset> = Asset.fetchRequest()

		if let result = try? dataController.viewContext.fetch(fetchRequest), result.count > 0 {
			for asset in result {
				total = total + asset.val
			}
		}
		totalFiatLabel.text = (self.fiatSign ?? "$") + self.formattedValue(total, decimals: 2)
	}

	fileprivate func configActivityView(animating: Bool) {
		if animating {
			self.activityIndicator.startAnimating()
		} else {
			self.activityIndicator.stopAnimating()
		}
		self.activityIndicator.isHidden = !animating
		self.activityIndicatorView.isHidden = !animating
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

		let cell = tableView.dequeueReusableCell(withIdentifier: "assetViewCell") as! AssetViewCell
		cell.setAsset(asset: asset, sign: fiatSign!, timeFrame: timeFrame!)

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
				let tokens = self.listings.filter({$0.id == Int(asset.id)})
				if tokens.count > 0 {
					detailVC.token = tokens[0]
					self.navigationController!.pushViewController(detailVC, animated: true)
				}
			}
		}))

		alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { action in
			let deleteAlert = UIAlertController(title: "Are You sure?", message: "\nDelete " + self.formattedValue(asset.total, decimals: 4) + " " + asset.symbol! + " tokens\n", preferredStyle: .alert)

			deleteAlert.addAction(UIAlertAction(title: "Yes", style: .destructive, handler: { action in
				self.deleteAsset(at: indexPath)
			}))

			deleteAlert.addAction(UIAlertAction(title: "No", style: .default, handler: nil))

			if let popoverController = deleteAlert.popoverPresentationController {
				popoverController.sourceView = self.view
				popoverController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
				popoverController.permittedArrowDirections = []
			}

			self.present(deleteAlert, animated: true)
		}))

		alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

		if let popoverController = alert.popoverPresentationController {
			popoverController.sourceView = self.view
			popoverController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
			popoverController.permittedArrowDirections = []
		}

		self.present(alert, animated: true, completion: nil)
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
		@unknown default:
			fatalError("Invalid change type in controller(_:didChange:atIndexPath:for:)")
		}
	}

	func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
		let indexSet = IndexSet(integer: sectionIndex)
		switch type {
		case .insert: assetsTableView.insertSections(indexSet, with: .fade)
		case .delete: assetsTableView.deleteSections(indexSet, with: .fade)
		case .update, .move:
			fatalError("Invalid change type in controller(_:didChange:atSectionIndex:for:). Only .insert or .delete should be possible.")
		@unknown default:
			fatalError("Invalid change type in controller(_:didChange:atSectionIndex:for:)")
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
			self.updateTotal()
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
	@IBOutlet weak var timeFrameLabel: UILabel!

	func setAsset(asset: Asset, sign: String, timeFrame: String) {
		guard let logoData = asset.logo else {
			return
		}

		var percentChange: Double?
		switch(timeFrame) {
		case "1h":
			percentChange = asset.pchange1h
		case "24h":
			percentChange = asset.pchange24h
		case "7d":
			percentChange = asset.pchange7d
		case "30d":
			percentChange = asset.pchange30d
		default:
			percentChange = asset.pchange24h
		}

		self.logoImageView.image = UIImage(data: logoData)
		self.symbolLabel.text = asset.symbol
		self.totalLabel.text = self.formattedValue(asset.total, decimals: 4) + " " + asset.symbol!
		self.priceLabel.text = sign + self.formattedValue(asset.val, decimals: 2)
		self.percentchangeLabel.text = self.formattedValue(percentChange!, decimals: 2, pSign: true) + "%"
		self.timeFrameLabel.text = timeFrame

		if self.percentchangeLabel.text!.starts(with: "+") {
			self.percentchangeLabel.textColor = UIColor(red: 0.22, green: 0.94, blue: 0.49, alpha: 1.00)
		} else if self.percentchangeLabel.text!.starts(with: "-"){
			self.percentchangeLabel.textColor = UIColor(red: 1.00, green: 0.25, blue: 0.42, alpha: 1.00)
		}
		self.timeFrameLabel.textColor = self.percentchangeLabel.textColor
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


