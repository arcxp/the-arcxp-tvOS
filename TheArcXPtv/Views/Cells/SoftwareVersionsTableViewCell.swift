//
//  SoftwareVersionsTableViewCell.swift
//  TheArcXPtv
//
//  Created by David Seitz Jr on 9/14/22.
//

import UIKit

class SoftwareVersionsTableViewCell: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var versionsLabel: UILabel!

    override func didUpdateFocus(in context: UIFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
        super.didUpdateFocus(in: context, with: coordinator)
        // Light mode focused color stays the standard color, while dark mode needs to be updated.
        let focusedColor = ThemeManager.lightModeEnabled ? ThemeManager.standardTextColor : ThemeManager.focusedTextColor
        titleLabel.textColor = context.nextFocusedView == self ? focusedColor : ThemeManager.standardTextColor
        versionsLabel.textColor = context.nextFocusedView == self ? focusedColor : ThemeManager.standardTextColor
    }

    func configureVersions(app: String, content: String, video: String) {
        versionsLabel.text = "• App: \(app)\n• Content SDK: \(content)\n• Video SDK: \(video)"
    }
}
