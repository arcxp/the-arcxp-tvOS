//
//  UIViewController+Storyboard.swift
//  TheArcXPtv
//
//  Created by Mahesh Venkateswarlu on 10/11/22.
//  Copyright © 2022 Arc XP. All rights reserved.
//

import UIKit

extension UIViewController {
    static func instantiate<T: UIViewController>() -> T {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let identifier = String(describing: T.self)
        guard let viewController = storyboard.instantiateViewController(withIdentifier: identifier) as? T else {
            fatalError("Storyboard ID is not same as \(identifier)")
        }
        return viewController as T
    }

    /// Show a standard error alert with the provided message and action.
    /// - parameter message: The message to be displayed with the alert.
    /// - parameter okAction: The action that will be executed upon the user tappping "OK".
    func presentErrorAlert(message: String, okAction: ((UIAlertAction) -> Void)? = nil) {
        let alertController = UIAlertController(title: UserFacingStrings.errorAlert, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: UserFacingStrings.okAlert, style: .default, handler: okAction)
        alertController.addAction(okAction)
        present(alertController, animated: true)
    }
}
