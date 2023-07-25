//
//  UITableViewCell+TheArcXPtv.swift
//  TheArcXPtv
//
//  Created by David Seitz Jr on 12/1/22.
//  Copyright © 2022 Arc XP. All rights reserved.
//

import Foundation
import UIKit

extension UITableViewCell {

    /// A standard UITableView error cell for displaying an error message.
    /// - parameter errorMessage: The message to be displayed with this error cell.
    /// - returns: A `UITableViewCell` to be used for displaying errors.
    static func errorCell(message: String) -> UITableViewCell {
        let errorCell = UITableViewCell()
        errorCell.textLabel?.text = message
        errorCell.imageView?.image = UIImage(systemName: Constants.ImageName.errorImage)
        return errorCell
    }
}
