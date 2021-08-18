//
//  Extensions.swift
//  CryptoPortfolio
//
//  Created by Adrian Gallardo on 16/08/21.
//

import Foundation
import UIKit

extension UIView{
	func addGradientBackground(colors: [CGColor], type: CAGradientLayerType){
		clipsToBounds = true
		let gradientLayer = CAGradientLayer()
		gradientLayer.type = type
		gradientLayer.colors = colors
		gradientLayer.frame = self.bounds

		switch type {
		case .axial:
			gradientLayer.startPoint = CGPoint(x: 1, y: 0)
			gradientLayer.endPoint = CGPoint(x: 1, y: 1)
		break
		case .radial:
			let endY = 0.5 + self.frame.size.width / self.frame.size.height / 2
			gradientLayer.endPoint = CGPoint(x: 1, y: endY)
		break
		default:
		break
		}

		self.layer.insertSublayer(gradientLayer, at: 0)
	}
}
