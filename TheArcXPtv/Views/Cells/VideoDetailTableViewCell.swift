//
//  VideoDetailTableViewCell.swift
//  TheArcXPtv
//
//  Created by David Seitz Jr on 9/14/22.
//

import UIKit
import os
import SDWebImage

protocol VideoPlayerDelegate: AnyObject {
    func playVideo(playFromBeginning: Bool)
}

class VideoDetailTableViewCell: UITableViewCell {

    weak var delegate: VideoPlayerDelegate?
    private static let logger = Logger(subsystem: Constants.bundleIdentifier,
                                       category: String(describing: VideoDetailViewController.self))
    var videoDetail: VideoDetail?

    @IBOutlet weak var videoTitleLabel: UILabel!
    @IBOutlet weak var videoDescriptionLabel: UILabel!
    @IBOutlet weak var publisherAndDateLabel: UILabel!
    @IBOutlet weak var resumeTimeLabel: UILabel!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var restartButton: UIButton!
    @IBOutlet weak var progressIndicator: UIProgressView!
    @IBOutlet weak var leftDetailLabels: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        contentView.clipsToBounds = false
        videoTitleLabel.textColor = ThemeManager.overImageLabelColor
        videoDescriptionLabel.textColor = ThemeManager.overImageLabelColor
        publisherAndDateLabel.textColor = ThemeManager.overImageLabelColor
        if let tintColor = ThemeManager.overImageButtonColor {
            playButton.configuration?.baseBackgroundColor = tintColor
            restartButton.configuration?.baseBackgroundColor = tintColor
        }
        playButton.configuration?.image = UIImage(systemName: Constants.ImageName.play)
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        progressIndicator.isHidden = true
    }

    @IBAction func playVideo(_ sender: UIButton) {
        switch sender {
        case playButton:
            delegate?.playVideo(playFromBeginning: false)
        case restartButton:
            delegate?.playVideo(playFromBeginning: true)
        default:
            break
        }
    }

    func configure(with videoDetail: VideoDetail) {
        self.videoDetail = videoDetail
        videoTitleLabel.text = videoDetail.title
        videoDescriptionLabel.text = videoDetail.videoDescription
        // Update play button status and resume time label
        if let playData = videoDetail.cachedPlayData {
            restartButton.isHidden = false
            progressIndicator.isHidden = false
            setProgressForProgressIndicator(resumeTime: playData.resumeTime, length: playData.length)
            let resumeTimeString = formatTimeFor(seconds: playData.resumeTime)
            let lengthString = formatTimeFor(seconds: playData.length)
            // These are casted to Ints because the Double values frequently don't match by a few small decimal points.
            let videoCompleted = Int(playData.length) == Int(playData.resumeTime)
            if Int(playData.resumeTime) != 0 && !videoCompleted {
                playButton.setTitle(UserFacingStrings.resume, for: .normal)
                restartButton.configuration?.image = UIImage(systemName: Constants.ImageName.restart)
                resumeTimeLabel.text = "\(resumeTimeString) / \(lengthString)"
            } else {
                playButton.setTitle(UserFacingStrings.replay, for: .normal)
                resumeTimeLabel.text = lengthString
                restartButton.isHidden = true
            }
            if Int(playData.resumeTime) == 0 {
                // When resumeTime is 0.0, Resume/Watch Again/Play From Beginning are not shown. Only
                // shown is the `Play` button
                restartButton.isHidden = true
                playButton.setTitle(UserFacingStrings.play, for: .normal)
                resumeTimeLabel.text = nil
            }
        } else {
            // TODO: AM-5216 - Make length/duration available, and show it in `resumeTimeLabel`
            playButton.setTitle(UserFacingStrings.play, for: .normal)
            resumeTimeLabel.text = nil
            restartButton.isHidden = true
        }

        // Set up publisher and publish date label
        if let publisher = videoDetail.credit,
           let publishDate = videoDetail.formattedPublishDate {
            publisherAndDateLabel.text = "\(publisher) • \(publishDate)"
        } else if let publisher = videoDetail.credit {
            Self.logger.error("Failed to get publish date for publisher and publish date label.")
            publisherAndDateLabel.text = publisher
        } else if let publishDate = videoDetail.formattedPublishDate {
            Self.logger.error("Failed to get publisher for publisher and publish date label.")
            publisherAndDateLabel.text = publishDate
        } else {
            Self.logger.error("Failed to populate publisher and publish date label.")
            publisherAndDateLabel.text = nil
        }
    }
    
    private func setProgressForProgressIndicator(resumeTime: Double, length: Double) {
        DispatchQueue.main.async {
            let progress = (resumeTime / length)
            self.progressIndicator.setProgress(Float(progress), animated: false)
        }
    }
}
