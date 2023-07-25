//
//  HeroSectionCollectionViewCell.swift
//  TheArcXPtv
//
//  Created by David Seitz Jr on 10/5/22.
//

import UIKit

class HeroSectionCollectionViewCell: VideoListCollectionViewCell {
    @IBOutlet weak var gradientView: GradientView!

    override func awakeFromNib() {
        super.awakeFromNib()
        selectedCellScale = 1.04
        gradientView.layer.cornerRadius = imageView.frame.height / VideoListCollectionViewCell.cornerRadiusHeightDivider
        titleLabel.textColor = ThemeManager.overImageLabelColor

        // Manage title label behavior
        hideTitleUnlessFocused = false
        titleLabel.alpha = 1
        titleLabel.numberOfLines = 0
        titleLabel.lineBreakMode = .byWordWrapping
    }

    override func didUpdateFocus(in context: UIFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
        super.didUpdateFocus(in: context, with: coordinator)
        coordinator.addCoordinatedAnimations { [weak self] in
            guard let self = self else { return }
            if self.isFocused {
                self.gradientView.transform = CGAffineTransform(scaleX: self.selectedCellScale,
                                                                y: self.selectedCellScale * 1.02)
            } else {
                self.gradientView.transform = CGAffineTransform(scaleX: VideoListCollectionViewCell.deselectedCellScale,
                                                                y: VideoListCollectionViewCell.deselectedCellScale)
            }
        }
    }
}
