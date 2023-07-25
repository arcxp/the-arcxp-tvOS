//
//  VideoListCollectionViewCell.swift
//  TheArcXPtv
//
//  Created by David Seitz Jr on 9/7/22.
//

import UIKit
import os

class VideoListCollectionViewCell: UICollectionViewCell {
    private static let logger = Logger(subsystem: Constants.bundleIdentifier,
                                       category: String(describing: VideoListCollectionViewCell.self))
    // Constants
    static let deselectedCellScale: CGFloat = 1
    static let cornerRadiusHeightDivider: CGFloat = 12

    // Properties
    var hideTitleUnlessFocused = false
    var selectedCellScale: CGFloat = 1.15
    var displayType: CellDisplayType = .videoContent
    // IBOutlets
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    @IBOutlet weak var progressIndicator: UIProgressView!
    @IBOutlet weak var videoListGradientView: GradientView!

    // MARK: - Lifecycle

    override func awakeFromNib() {
        super.awakeFromNib()
        imageView.layer.cornerRadius = imageView.frame.height / VideoListCollectionViewCell.cornerRadiusHeightDivider
        titleLabel.numberOfLines = 0
        titleLabel.alpha = hideTitleUnlessFocused ? 0 : 1
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.minimumScaleFactor = 0.5
        loadingIndicator.hidesWhenStopped = true
        if let gradientView = videoListGradientView {
            gradientView.layer.cornerRadius = imageView.frame.height / VideoListCollectionViewCell.cornerRadiusHeightDivider
        }
        titleLabel.textColor = ThemeManager.standardTextColor
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.sd_cancelCurrentImageLoad()
        imageView.image = nil
        progressIndicator?.isHidden = true
        videoListGradientView?.isHidden = true
    }

    func configure(with videoListItem: VideoListItem?) {
        guard let videoListItem = videoListItem else {
            Self.logger.error("Video list item was nil while trying to configure a video list collection view cell.")
            return
        }
        titleLabel.text = videoListItem.title
        loadingIndicator.startAnimating()

        if let imageUrlString = videoListItem.imageUrlString {
            imageView.sd_setImage(with: URL(string: imageUrlString)) { [weak self] _, error, _, _ in
                DispatchQueue.main.async {
                    self?.loadingIndicator.stopAnimating()
                }
                if let error = error {
                    DispatchQueue.main.async {
                        self?.imageView.backgroundColor = .lightGray
                        self?.imageView.image = UIImage(systemName: Constants.ImageName.errorImage)
                    }
                    Self.logger.error("There was an error while loading an image. Error:\(error.localizedDescription)")
                }
            }
        } else {
            imageView.backgroundColor = .lightGray
            imageView.image = UIImage(systemName: Constants.ImageName.errorImage)
            loadingIndicator.stopAnimating()
        }
        determineDisplayType(with: videoListItem.id)
    }

    private func determineDisplayType(with id: String?) {
        switch displayType {
        case .continueWatching:
            guard let id = id else {return}
            do {
                let details = try CacheManager.getCachedVideo(with: id)
                if let resumeTime = details?.cachedPlayData?.resumeTime,
                    let length = details?.cachedPlayData?.length {
                    DispatchQueue.main.async {
                        // Progress formula = (watchTime/Length)
                        let progress = (resumeTime / length)
                        self.videoListGradientView.isHidden = false
                        self.progressIndicator.isHidden = false
                        self.progressIndicator.setProgress(Float(progress), animated: false)
                    }
                }
            } catch let error {
                let errorMessage = "There was an error while reading cachedPlayData. Error: \(error.localizedDescription)"
                Self.logger.error("\(errorMessage)")
            }
        default:
            break
        }
    }

    override func didUpdateFocus(in context: UIFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
        coordinator.addCoordinatedAnimations { [weak self] in
            guard let self = self else { return }
            if self.isFocused {
                self.imageView.transform = CGAffineTransform(scaleX: self.selectedCellScale, y: self.selectedCellScale)
                self.titleLabel.alpha = 1
                if let gradientView = self.videoListGradientView {
                    gradientView.transform = CGAffineTransform(scaleX: self.selectedCellScale,
                                                                    y: self.selectedCellScale * 1.02)
                }
            } else {
                self.imageView.transform = CGAffineTransform(scaleX: VideoListCollectionViewCell.deselectedCellScale,
                                                             y: VideoListCollectionViewCell.deselectedCellScale)
                if self.hideTitleUnlessFocused { self.titleLabel.alpha = 0 }
                if let gradientView = self.videoListGradientView {
                    gradientView.transform = CGAffineTransform(scaleX: VideoListCollectionViewCell.deselectedCellScale,
                                                                    y: VideoListCollectionViewCell.deselectedCellScale)
                }
            }
        }
    }

    // MARK: - Convenience Methods

    func setErrorImagePlaceholder() {
        imageView.image = UIImage(systemName: Constants.ImageName.errorImage)
    }

    enum CellDisplayType {
        case videoContent
        case hero
        case liveEvent
        case continueWatching
    }
}
