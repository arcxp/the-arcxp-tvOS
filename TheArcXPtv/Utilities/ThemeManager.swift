//
//  ThemeManager.swift
//  TheArcXPtv
//
//  Created by David Seitz Jr on 1/24/23.
//  Copyright © 2023 Arc XP. All rights reserved.
//

import UIKit

struct ThemeManager {
    private static var tintColorLightMode: UIColor?
    private static var tintColorDarkMode: UIColor?
    private static var tintColorOverImage: UIColor?

    /// Determines whether or not the system is in light mode, indicating whether colors should be updated for light mode.
    static var lightModeEnabled: Bool {
        switch UIViewController().traitCollection.userInterfaceStyle {
        case .light:
            return true
        default:
            // This returns false for both dark and unspecified cases.
            // Unspecified is being lumped in with the "dark" case because dark mode is
            // on by default when restarting the tvOS system.
            return false
        }
    }

    /// The color to be used for text labels over images. Images are expected to have dark gradients to help the label's legibility.
    static var overImageLabelColor: UIColor {
        return .white
    }

    static var overImageButtonColor: UIColor? {
        return tintColorOverImage
    }

    /// The color to be used on standard text, such as list cells and text views.
    static var standardTextColor: UIColor {
        return lightModeEnabled ? .black : .white
    }

    static var focusedTextColor: UIColor {
        return lightModeEnabled ? .white : .black
    }

    /// The color to be used on UI elements, varying based on light and dark modes.
    static var tintColor: UIColor? {
        return lightModeEnabled ? tintColorLightMode : tintColorDarkMode
    }

    /// Set the preferred tint colors for light and dark modes.
    /// - parameter lightMode: The tint color to be used while the system is in light mode.
    /// - parameter darkMode: The tint color to be used while the system is in dark mode.
    static func setTintColor(lightMode: UIColor,
                             darkMode: UIColor,
                             overImage: UIColor) {
        tintColorLightMode = lightMode
        tintColorDarkMode = darkMode
        tintColorOverImage = overImage
        // Note: Setting "focused" tint colors requires more involved customization, and
        // needs to be handled within custom buttons. For now, we'll stick with the
        // standard focused colors, until a desire for custom focused colors is expressed.
    }

    /// A centralized handler for updating 
    static func font(name: String, size: CGFloat) -> UIFont? {
        let font = UIFont(name: name, size: size)
        return font
    }
}
