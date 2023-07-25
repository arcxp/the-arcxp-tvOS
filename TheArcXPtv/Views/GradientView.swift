//
//  GradientView.swift
//  TheArcXPtv
//
//  Created by David Seitz Jr on 10/20/22.
//  Copyright © 2022 Arc XP. All rights reserved.
//

import UIKit
import os

@IBDesignable class GradientView: UIView {

    private static let logger = Logger(subsystem: Constants.bundleIdentifier, category: String(describing: GradientView.self))

    var gradientLayer: CAGradientLayer {
        // swiftlint:disable force_cast
        return layer as! CAGradientLayer
        // swiftlint:enable force_cast
    }

    override open class var layerClass: AnyClass {
        return CAGradientLayer.classForCoder()
    }

    @IBInspectable var startColor: UIColor? {
        didSet { gradientLayer.colors = cgColorGradient }
    }

    @IBInspectable var endColor: UIColor? {
        didSet { gradientLayer.colors = cgColorGradient }
    }

    @IBInspectable var startPoint: CGPoint = CGPoint(x: 0.0, y: 0.0) {
        didSet { gradientLayer.startPoint = startPoint }
    }

    @IBInspectable var endPoint: CGPoint = CGPoint(x: 1.0, y: 1.0) {
        didSet { gradientLayer.endPoint = endPoint }
    }

    internal var cgColorGradient: [CGColor]? {
        guard let startColor = startColor, let endColor = endColor else {
            Self.logger.error("Failed to access gradient colors.")
            return nil
        }

        return [startColor.cgColor, endColor.cgColor]
    }
}
