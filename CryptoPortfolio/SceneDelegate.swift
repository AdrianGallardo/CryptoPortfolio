//
//  SceneDelegate.swift
//  CryptoPortfolio
//
//  Created by Adrian Gallardo on 22/04/21.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

	var window: UIWindow?
	let dataController = DataController(modelName: "CryptoPortfolio")

	func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
		// Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
		// If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
		// This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
		dataController.load()

		let tabBarController = window?.rootViewController as! UITabBarController

		let navigationController1 = tabBarController.viewControllers![1] as! UINavigationController
		let navigationController2 = tabBarController.viewControllers![2] as! UINavigationController

		let assetsViewController = navigationController1.topViewController as! AssetsViewController
		let settingsViewController = navigationController2.topViewController as! SettingsViewController

		assetsViewController.dataController = dataController
		settingsViewController.dataController = dataController

		guard let _ = (scene as? UIWindowScene) else { return }
	}
}

