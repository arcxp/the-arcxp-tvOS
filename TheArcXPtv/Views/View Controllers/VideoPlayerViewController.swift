//
//  VideoPlayerViewController.swift
//  TheArcXPtv
//
//  Created by Mahesh Venkateswarlu on 10/5/22.
//  Copyright © 2022 Arc XP. All rights reserved.
//

import AVKit
import ArcXP
import os

public enum PlayerMode {
    case avPlayerViewController
    case arcMediaPlayerViewController
}

class VideoPlayerViewController: UIViewController {

    public var playerMode: PlayerMode = .avPlayerViewController

    /// The `PlayerController` that was provided by the
    /// `playerControllerContainer`. **If you do not assign the player
    /// controller to an instance property, and you use the
    /// `AVPlayerViewController`, your app will crash because the
    /// `AVPlayerViewController` does *not* retain the `playerController`
    /// itself.
    private var playerController: PlayerController!

    private var videoDetail: VideoDetail?
    private var seekToPlayerTime: Double?
    private static let logger = Logger(subsystem: Constants.bundleIdentifier,
                                       category: String(describing: VideoPlayerViewController.self))
    var playFromBeginning = false

    // MARK: - Lifecycle

    static func instantiate(videoDetail: VideoDetail) -> VideoPlayerViewController {
        let videoPlayerViewController = VideoPlayerViewController.instantiate() as VideoPlayerViewController
        videoPlayerViewController.videoDetail = videoDetail
        return videoPlayerViewController
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        guard let videoDetail = videoDetail,
              let videoID = videoDetail.id else {
                  Self.logger.error("Failed to load video detail or video ID.")
                  return
              }

        // Here we check if the video should be played from the beginning,
        // if not we resume with the cached time.
        if !playFromBeginning, let playData = videoDetail.cachedPlayData {
            seekToPlayerTime = playData.resumeTime
        }

        let playerViewController: UIViewController
        
        // Figure out which player controller container we want.
        if playerMode == .arcMediaPlayerViewController {
            let playerVC = ArcMediaPlayerViewController.loadFromStoryboard()
            playerVC.playerView.delegate = self
            playerController = playerVC.playerController
            playerViewController = playerVC
        } else {
            let playerVC = AVPlayerViewController()
            playerController = playerVC.playerController
            playerViewController = playerVC
        }
        playerController.delegate = self
        
        addChild(playerViewController)
        playerViewController.didMove(toParent: self)  // DON'T FORGET THIS!
        view.addSubview(playerViewController.view)
        let playerView = playerViewController.view!
        playerView.translatesAutoresizingMaskIntoConstraints = false
        playerView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        playerView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        playerView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        playerView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        playVideo(with: videoID)
    }

    // MARK: - Convenience Methods
    
    private func log(_ message: String, playerTime: CMTime) {
        Self.logger.log(level: .default, "\(message) + Player time: \(String(describing: playerTime))")
    }
    
    private func playVideo(with videoID: String) {
        ArcMediaClientManager.client.video(mediaID: videoID,
                                           adSettings: nil,
                                           accessToken: "unused") { [weak self] result in
            guard let self = self else {
                // This instance of video player view controller isn't available. Don't attempt to play.
                return
            }
            switch result {
            case .success(let video):
                let playerItem = AVPlayerItem(asset: video)
                self.playerController?.play(playerItem: playerItem)
                if let seekTo = self.seekToPlayerTime,
                   Int(seekTo) != Int(playerItem.asset.duration.seconds) {
                    Task { [weak self] in
                        await self?.playerController.player.seek(to: CMTime(seconds: seekTo, preferredTimescale: 1))
                    }
                }

            case .failure:
                Self.logger.error("\(UserFacingStrings.videoLoadError)")
                self.presentErrorAlert(message: UserFacingStrings.videoLoadError)
            }
        }
    }
    
    private func loadVideo(video: ArcVideo?) {
        if let video = video {
            let playerItem = AVPlayerItem(asset: video)
            playerController?.load(playerItem: playerItem)
        }
    }
    
    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        playerController?.pause()
    }
}

extension VideoPlayerViewController: PlayerDelegate {
    // MARK: - Playback Milestones

    func player(_ player: AVPlayer, completed item: AVPlayerItem?) {
        log("Video completed", playerTime: player.currentTime())
    }

    func player(_ player: AVPlayer, played25Percent video: AVPlayerItem?) {
        log("Video is 25% finished", playerTime: player.currentTime())
    }

    func player(_ player: AVPlayer, played50Percent video: AVPlayerItem?) {
        log("Video is 50% finished", playerTime: player.currentTime())
    }

    func player(_ player: AVPlayer, played75Percent video: AVPlayerItem?) {
        log("Video is 75% finished", playerTime: player.currentTime())
    }

    // MARK: - User Interaction

    func playerMuted(_ player: AVPlayer) {
        log("Player muted", playerTime: player.currentTime())
    }

    func playerUnmuted(_ player: AVPlayer) {
        log("Player unmuted", playerTime: player.currentTime())
    }

    func player(_ player: AVPlayer, paused video: AVPlayerItem?) {
        log("Video paused", playerTime: player.currentTime())
        // Save the video into cache when paused to resume/recently_watched_videos
        guard let videoDetail = videoDetail else {
            Self.logger.error("\(UserFacingStrings.videoCacheError)")
            presentErrorAlert(message: UserFacingStrings.videoCacheError)
            return
        }
        let video = Video(videoDetail: videoDetail,
                          resumeTime: player.currentItem?.currentTime().seconds,
                          length: player.currentItem?.duration.seconds,
                          lastViewedTime: Date())
        do {
            if !videoDetail.isLiveVideo {
                try CacheManager.cache(videos: [video])
            }
        } catch {
            let errorMessage = "\(UserFacingStrings.videoCacheError) \(error.localizedDescription)"
            Self.logger.error("\(errorMessage)")
            presentErrorAlert(message: errorMessage)
        }
    }

    func player(_ player: AVPlayer, resumed item: AVPlayerItem?) {
        log("Video resumed", playerTime: player.currentTime())
    }

    func player(_ player: AVPlayer, skipped item: AVPlayerItem?, to time: CMTime) {
        log("Video skipped to \(time.seconds)", playerTime: player.currentTime())
    }

    func player(_ player: AVPlayer, started video: AVPlayerItem?, byUser: Bool) {
        log("Video started" + (byUser ? " by the user" : " automatically"), playerTime: player.currentTime())
    }

    func playerTapped(_ player: AVPlayer, item: AVPlayerItem?) {
        log("Player tapped", playerTime: player.currentTime())
    }

    func playerBeganFullScreenPresentation(_ player: AVPlayer, item: AVPlayerItem?) {
        log("Player went into fullscreen mode", playerTime: player.currentTime())
    }

    func playerEndedFullScreenPresentation(_ player: AVPlayer, item: AVPlayerItem?) {
        log("Player returned from fullscreen mode", playerTime: player.currentTime())
    }
}

extension VideoPlayerViewController: ArcMediaPlayerViewDelegate {

    func playerViewControlBarDidAppear(_ playerView: ArcMediaPlayerView) {
        log("Control bar appeared", playerTime: playerView.player.currentTime())
    }

    func playerViewControlBarWillAppear(_ playerView: ArcMediaPlayerView) {
        log("Control bar will appear", playerTime: playerView.player.currentTime())
    }

    func playerViewControlBarDidDisappear(_ playerView: ArcMediaPlayerView) {
        log("Control bar disappeared", playerTime: playerView.player.currentTime())
    }

    func playerViewControlBarWillDisappear(_ playerView: ArcMediaPlayerView) {
        log("Control bar will disappear", playerTime: playerView.player.currentTime())
    }
}
