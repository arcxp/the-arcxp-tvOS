//
//  VideoDetailViewController.swift
//  TheArcXPtv
//
//  Created by David Seitz Jr on 9/8/22.
//  Copyright © 2022 Arc XP. All rights reserved.
//

import UIKit
import os

class VideoDetailViewController: UIViewController {

    private static let logger = Logger(subsystem: Constants.bundleIdentifier,
                                       category: String(describing: VideoDetailViewController.self))
    // Constants
    private static let videoDetailTableViewCell = "VideoDetailTableViewCell"
    private static let videoListTableViewCell = "VideoListTableViewCell"

    // Properties
    private var videoDetailViewModel: VideoDetail?
    private var relatedVideosList: [VideoListItem]?
    private let videoImageView = UIImageView(frame: UIScreen.main.bounds)
    private let gradient = GradientView(frame: UIScreen.main.bounds)
    
    // IBOutlets
    @IBOutlet weak var tableView: UITableView!

    // View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpTableView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }

    func configure(videoDetail: VideoDetail, relatedVideos: [VideoListItem]?) {
        videoDetailViewModel = videoDetail
        relatedVideosList = relatedVideos
    }

    // Convenience Methods

    private func setUpTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.insetsContentViewsToSafeArea = false
        tableView.insetsLayoutMarginsFromSafeArea = false
        tableView.contentInsetAdjustmentBehavior = .never

        let videoDetailCellNib = UINib(nibName: VideoDetailViewController.videoDetailTableViewCell, bundle: .main)
        tableView.register(videoDetailCellNib, forCellReuseIdentifier: VideoDetailViewController.videoDetailTableViewCell)
        let videoListTableViewCellNib = UINib(nibName: VideoDetailViewController.videoListTableViewCell, bundle: .main)
        tableView.register(videoListTableViewCellNib, forCellReuseIdentifier: VideoDetailViewController.videoListTableViewCell)
        setupImageBackground()
    }

    private func dequeueReusableVideoDetailCell(indexPath: IndexPath) -> VideoDetailTableViewCell? {
        guard let videoDetail = videoDetailViewModel,
              let videoDetailCell = tableView.dequeueReusableCell(
                withIdentifier: VideoDetailViewController.videoDetailTableViewCell) as? VideoDetailTableViewCell else {
            Self.logger.error("\(UserFacingStrings.cellUIError)")
            presentErrorAlert(message: UserFacingStrings.cellUIError)
            return nil
        }
        videoDetailCell.configure(with: videoDetail)
        videoDetailCell.delegate = self
        return videoDetailCell
    }

    private func dequeueReusableVideoListCell(indexPath: IndexPath) -> VideoListTableViewCell? {
        guard let videoListCell = tableView.dequeueReusableCell(
            withIdentifier: VideoDetailViewController.videoListTableViewCell) as? VideoListTableViewCell else {
                Self.logger.error("\(UserFacingStrings.cellUIError)")
                presentErrorAlert(message: UserFacingStrings.cellUIError)
                return nil
            }
        videoListCell.configure(videoList: relatedVideosList, listName: UserFacingStrings.relatedVideos)
        videoListCell.delegate = self
        return videoListCell
    }
    
    private func setupImageBackground() {
        gradient.startColor = .clear
        gradient.endColor = .black
        videoImageView.contentMode = .scaleAspectFill
        view.insertSubview(videoImageView, at: 0)
        videoImageView.insertSubview(gradient, at: 0)
        guard let videoDetail = videoDetailViewModel  else { return }
        if let imageUrlString = videoDetail.imageUrlString {
            videoImageView.sd_setImage(with: URL(string: imageUrlString)) { _, error, _, _ in
                if let error = error {
                    Self.logger.error("There was an error while loading an image. Error: \(error.localizedDescription)")
                }
            }
        }
    }
}

// MARK: - Table View

extension VideoDetailViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
        case 0:
            guard let videoDetailCell = dequeueReusableVideoDetailCell(indexPath: indexPath) else {
                Self.logger.error("\(UserFacingStrings.cellUIError)")
                return .errorCell(message: UserFacingStrings.cellUIError)
            }
            return videoDetailCell

        default:
            guard let videoListCell = dequeueReusableVideoListCell(indexPath: indexPath) else {
                Self.logger.error("\(UserFacingStrings.cellUIError)")
                return .errorCell(message: UserFacingStrings.cellUIError)
            }
            return videoListCell
        }
    }

    func tableView(_ tableView: UITableView, canFocusRowAt indexPath: IndexPath) -> Bool {
        return false
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let screenHeight = UIScreen.main.bounds.height - 170
        return indexPath.row == 0 ? screenHeight : 350
    }
}

// MARK: - VideoPlayerDelegate

extension VideoDetailViewController: VideoPlayerDelegate {
    func playVideo(playFromBeginning: Bool) {
        guard let videoDetail = videoDetailViewModel else {
            Self.logger.error("\(UserFacingStrings.videoDetailError)")
            presentErrorAlert(message: UserFacingStrings.videoDetailError)
            return
        }
        let videoPlayerViewController = VideoPlayerViewController.instantiate(videoDetail: videoDetail)
        videoPlayerViewController.playFromBeginning = playFromBeginning
        present(videoPlayerViewController, animated: false)
    }
}

// MARK: - VideoListTableViewCellDelegate

extension VideoDetailViewController: VideoListTableViewCellDelegate {
    func didSelectVideo(videoDetail: VideoDetail, from videoList: [VideoListItem]?) {
        let videoDetailViewController = VideoDetailViewController.instantiate() as VideoDetailViewController
        videoDetailViewController.configure(videoDetail: videoDetail, relatedVideos: videoList)
        present(videoDetailViewController, animated: true)
    }
}
