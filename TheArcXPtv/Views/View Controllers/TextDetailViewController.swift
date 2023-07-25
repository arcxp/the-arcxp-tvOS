//
//  TextDetailViewController.swift
//  TheArcXPtv
//
//  Created by David Seitz Jr on 9/14/22.
//  Copyright © 2022 Arc XP. All rights reserved.
//

import UIKit

class TextDetailViewController: UIViewController {
    private static let textDetailViewController = "TextDetailViewController"
    var textDetailTitle: String?
    var textDetailText: NSAttributedString?
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var textView: UITextView!

    /// Create a new instance of `TextDetailViewController` to be used modularly.
    static func instantiate(title: String, text: NSAttributedString) -> TextDetailViewController {
        let textDetailViewController = TextDetailViewController.instantiate() as TextDetailViewController
        textDetailViewController.textDetailTitle = title
        textDetailViewController.textDetailText = text
        return textDetailViewController
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        titleLabel.text = textDetailTitle
        textView.attributedText = textDetailText
        titleLabel.textColor = ThemeManager.standardTextColor
        textView.textColor = ThemeManager.standardTextColor
        textView.tintColor = ThemeManager.tintColor
        // Allow the text view to scroll based on remote touch.
        textView.isUserInteractionEnabled = true
        textView.panGestureRecognizer.allowedTouchTypes = [UITouch.TouchType.indirect.rawValue as NSNumber]
    }
}
