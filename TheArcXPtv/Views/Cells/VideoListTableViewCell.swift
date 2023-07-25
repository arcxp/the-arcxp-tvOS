//
//  VideoListTableViewCell.swift
//  TheArcXPtv
//
//  Created by David Seitz Jr on 9/7/22.
//

import UIKit
import os

protocol VideoListTableViewCellDelegate: AnyObject {
    // This allows the collection view to report when a video has been selected
    // to the HomeViewController, which is responsible for presenting the next view controller.
    func didSelectVideo(videoDetail: VideoDetail, from videoList: [VideoListItem]?)
}

class VideoListTableViewCell: UITableViewCell {
    private static let logger = Logger(subsystem: Constants.bundleIdentifier,
                                       category: String(describing: VideoListTableViewCell.self))
    // Constants
    private let collectionViewCellWidth = 350
    private let collectionViewCellHeight = 280
    private let heroSectionCellHeight = 700
    private let heroSectionCellWidth = 1650
    private let collectionViewCellMinimumSpacing: CGFloat = 50
    private let videoListCollectionViewCell = "VideoListCollectionViewCell"
    private let heroSectionCollectionViewCell = "HeroSectionCollectionViewCell"
    
    // Properties
    private var videoList: [VideoListItem]?
    var isLiveRow = false
    var isContinueWatchingRow = false
    private var displayHeroSection = false
    weak var delegate: VideoListTableViewCellDelegate?

    // IBOutlets
    @IBOutlet weak var sectionHeaderLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!

    override func awakeFromNib() {
        super.awakeFromNib()
        contentView.clipsToBounds = false
        clipsToBounds = false
        setUpCollectionView()
        sectionHeaderLabel.textColor = ThemeManager.standardTextColor
    }

    func configure(videoList: [VideoListItem]?, listName: String?, displayHeroSection: Bool = false, isContinueWatchingRow: Bool = false) {
        self.videoList = videoList
        self.sectionHeaderLabel.text = listName ?? UserFacingStrings.videos
        self.displayHeroSection = displayHeroSection
        self.isContinueWatchingRow = isContinueWatchingRow
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        self.videoList = nil
        self.displayHeroSection = false
    }

    private func setUpCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.clipsToBounds = false
        collectionView.backgroundColor = .clear
        let collectionViewCellNib = UINib(nibName: videoListCollectionViewCell, bundle: .main)
        let heroSectionCollectionViewCellNib = UINib(nibName: heroSectionCollectionViewCell, bundle: .main)
        collectionView.register(collectionViewCellNib, forCellWithReuseIdentifier: videoListCollectionViewCell)
        collectionView.register(heroSectionCollectionViewCellNib, forCellWithReuseIdentifier: heroSectionCollectionViewCell)
    }

    // swiftlint:disable line_length
    private func dequeueReusableHeroCell(indexPath: IndexPath) -> HeroSectionCollectionViewCell? {
        let heroCell = collectionView.dequeueReusableCell(withReuseIdentifier: heroSectionCollectionViewCell, for: indexPath) as? HeroSectionCollectionViewCell
        heroCell?.configure(with: videoList?[indexPath.row])
        return heroCell
    }

    private func dequeueReusableVideoListCell(indexPath: IndexPath) -> VideoListCollectionViewCell? {
        let videoListCell = collectionView.dequeueReusableCell(withReuseIdentifier: videoListCollectionViewCell, for: indexPath) as? VideoListCollectionViewCell
        if isContinueWatchingRow {
            videoListCell?.displayType = .continueWatching
        }
        videoListCell?.configure(with: videoList?[indexPath.row])
        return videoListCell
    }
    // swiftlint:enable line_length
}

// MARK: Video List Table View Cell

extension VideoListTableViewCell: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // Note that a predefined limit of 20 cells maximum was determined by product in ticket AM-5074.
        return videoList?.count ?? 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if displayHeroSection { return dequeueReusableHeroCell(indexPath: indexPath) ?? UICollectionViewCell() }
        return dequeueReusableVideoListCell(indexPath: indexPath) ?? UICollectionViewCell()
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = displayHeroSection ? heroSectionCellWidth : collectionViewCellWidth
        let height = displayHeroSection ? heroSectionCellHeight : collectionViewCellHeight
        return CGSize(width: width, height: height)
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return collectionViewCellMinimumSpacing
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let videoDetail = videoList?[indexPath.row] as? VideoDetail {
            delegate?.didSelectVideo(videoDetail: videoDetail, from: videoList)
        } else {
            Self.logger.error("Failed to get video detail for cell.")
        }
    }
}
