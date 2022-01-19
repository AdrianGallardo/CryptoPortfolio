//
//  RadialGradientView.swift
//  CryptoPortfolio
//
//  Created by Adrian Gallardo on 19/01/22.
//

import Foundation
import UIKit

class RadialGradientView: UIView {
	let colorsMidnight = [UIColor(red: 0.25, green: 0.26, blue: 0.27, alpha: 1.00).cgColor,
												UIColor(red: 0.14, green: 0.15, blue: 0.15, alpha: 1.00).cgColor]

	let gradientLayer = CAGradientLayer()

	override init(frame: CGRect) {
		super.init(frame: frame)
		commonInit()
	}

	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		commonInit()
	}

	private func commonInit() {
		gradientLayer.colors = colorsMidnight
		gradientLayer.type = CAGradientLayerType.radial
		let endY = 0.5 + self.frame.size.width / self.frame.size.height / 2
		gradientLayer.endPoint = CGPoint(x: 1, y: endY)
		layer.addSublayer(gradientLayer)
	}

	override open func layoutSubviews() {
		super.layoutSubviews()

		if gradientLayer.frame != bounds {
			gradientLayer.frame = bounds
		}
	}
}
