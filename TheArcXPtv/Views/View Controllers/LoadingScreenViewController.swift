//
//  LoadingScreenViewController.swift
//  TheArcXPtv
//
//  Created by David Seitz Jr on 11/15/22.
//  Copyright © 2022 Arc XP. All rights reserved.
//

import UIKit
import os
import ArcXP

class LoadingScreenViewController: UIViewController {
    private static let logger = Logger(subsystem: Constants.bundleIdentifier,
                                       category: String(describing: LoadingScreenViewController.self))

    private var destinationViewController: UIViewController?

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        preloadContent()
    }

    func setUp(destinationViewController: UIViewController?) {
        self.destinationViewController = destinationViewController
    }

    private func proceedToDestinationViewController(sectionList: SectionList?,
                                                    contentLists: [ContentListCollection]?,
                                                    liveEvents: [LiveEvent]?) {

        guard let tabBarController = destinationViewController as? UITabBarController,
              let destinationVC = tabBarController.viewControllers?.first as? HomeViewController else {
            Self.logger.error("\(UserFacingStrings.loadingScreenError)")
            presentErrorAlert(message: UserFacingStrings.loadingScreenError)
            return
        }
        destinationVC.injectPreloadedContent(sectionList: sectionList, contentLists: contentLists, liveVideos: liveEvents)
        show(tabBarController, sender: self)
    }

    /// Load content here in the loading screen so that, when the `HomeViewController` is shown, content displays immediately.
    private func preloadContent() {
        Task {
            do {
                let sectionList = try await ContentProvider.fetchSectionList(siteHierarchy: Constants.ContentConfig.siteHierarchyName)
                let contentLists = try await ContentProvider.fetchContentLists(sectionList: sectionList)
                let liveVideos = try await ContentProvider.fetchLiveVideos()
                proceedToDestinationViewController(sectionList: sectionList, contentLists: contentLists, liveEvents: liveVideos)
            } catch {
                let errorMessage = "\(UserFacingStrings.defaultContentFetchErrorMessage) \(error.localizedDescription)."
                Self.logger.error("\(errorMessage)")
                presentErrorAlert(message: errorMessage) { [weak self] _ in
                    self?.proceedToDestinationViewController(sectionList: nil, contentLists: nil, liveEvents: nil)
                }
            }
        }
    }
}
