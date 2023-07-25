//
//  AppDelegate.swift
//  TheArcXPtv
//
//  Created by Cassandra Balbuena on 8/25/22.
//

import UIKit
import os

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    private static let logger = Logger(subsystem: Constants.bundleIdentifier, category: String(describing: AppDelegate.self))
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions
                     launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        ContentProvider.configureArcXPSDKs()
        CoreDataController.setUp()
        customizeTheme()
        guard setUpLoadingScreen() else { return false }
        return true
    }

    private func customizeTheme() {
        // Theme customization
        let lightModeTintColor = UIColor(red: 0/255,
                                         green: 34/255,
                                         blue: 64/255,
                                         alpha: 1)
        let darkModeTintColor = UIColor(red: 62/255,
                                        green: 187/255,
                                        blue: 185/255,
                                        alpha: 1)
        ThemeManager.setTintColor(lightMode: lightModeTintColor,
                                  darkMode: darkModeTintColor,
                                  overImage: darkModeTintColor)
    }

    /// A loading screen that indicates that content is still being loaded after launching.
    private func setUpLoadingScreen() -> Bool {
        guard let loadingScreenViewController = self.window?.rootViewController as? LoadingScreenViewController else {
            Self.logger.error("Failed to get loading screen as initial view controller.")
            return false
        }
        loadingScreenViewController.setUp(destinationViewController: setUpTabBarController())
        return true
    }

    /// Due to the Search view controller needing to be set up a specific way, this function manually
    /// adds each view controller to preserve the desired ordering: Home, Search, Settings.
    /// If Search were simply added to the tab bar while Home and Settings connections were defined in storyboard,
    /// it would result in the wrong ordering, with Search appearing after Settings.
    /// - returns: A boolean indicating whether view controllers were added to the tab bar controler successfully.
    private func setUpTabBarController() -> MainTabBarController? {
        let tabBarController = MainTabBarController()

        let mainStoryboard = UIStoryboard(name: Constants.mainStoryboardName, bundle: Bundle.main)

        guard let homeVC = mainStoryboard.instantiateViewController(withIdentifier: "HomeViewController") as? HomeViewController else {
            Self.logger.error("Failed to get HomeViewController from the main storyboard.")
            return nil
        }
        homeVC.title = UserFacingStrings.home

        let searchVC = SearchResultsController.setUpSearch(storyboard: mainStoryboard)

        guard let settingsVC = mainStoryboard
                .instantiateViewController(withIdentifier: "SettingsViewController") as? SettingsViewController else {
                    Self.logger.error("Failed to load SettingsViewController.")
                    return nil
                }
        settingsVC.title = UserFacingStrings.settings

        tabBarController.viewControllers = [homeVC, searchVC, settingsVC]

        return tabBarController
    }
}
