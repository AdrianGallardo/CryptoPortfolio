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

	let colorsMidnight = [UIColor(red: 0.25, green: 0.26, blue: 0.27, alpha: 1.00).cgColor,
												UIColor(red: 0.14, green: 0.15, blue: 0.15, alpha: 1.00).cgColor]

	override func viewDidLoad() {
		super.viewDidLoad()
		self.navigationController?.isNavigationBarHidden = false

		headerView.addGradientBackground(colors: colorsMidnight, type: CAGradientLayerType.axial)
	}
}
