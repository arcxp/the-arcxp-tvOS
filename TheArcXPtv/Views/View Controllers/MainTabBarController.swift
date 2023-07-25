//
//  MainTabBarController.swift
//  TheArcXPtv
//
//  Created by David Seitz Jr on 11/15/22.
//  Copyright © 2022 Arc XP. All rights reserved.
//

import UIKit

class MainTabBarController: UITabBarController {
    override func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
        /// Overriding this function to prevent going back to the loading screen when the user presses "menu" or "back" buttons.
    }
}
