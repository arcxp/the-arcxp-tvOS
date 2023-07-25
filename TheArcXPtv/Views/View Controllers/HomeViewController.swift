//
//  ViewController.swift
//  The ArcXP TV
//
//  Created by Cassandra Balbuena on 8/22/22.
//  Copyright © 2022 Arc XP. All rights reserved.
//

import UIKit
import ArcXP
import os

typealias ContentListCollection = (alias: String, contentList: ArcXPContentList)

class HomeViewController: UIViewController {

    private static var logger = Logger(subsystem: Constants.bundleIdentifier, category: String(describing: HomeViewController.self))

    // Constants
    /// Name and reuse ID for video list table view cells.
    private let videoListTableViewCell = "VideoListTableViewCell"

    /// Represents the sections displayed on the Home screen, with each section being it's own row.
    private var sectionList: SectionList?

    /// Represents the items displayed in each row of the Home screen, with the items populating individual rows.
    private var contentLists: [ContentListCollection]?

    private var liveVideos: [VideoListItem] = []
    
    /// Represents the list of videos the user has recently watched but did not finish.
    private var continueWatchingVideos: [VideoListItem] = []

    private var liveEventTimer: Timer?
    
    private let liveEventsRowIndex = 1
    
    /// Represents the possible types of the rows in displayed in the Home screen.
    enum RowType {
        case heroRow(info: (alias: String, title: String?))
        case liveEvent
        case continueWatching
        case videoContent(info: (alias: String, title: String?))
    }
    
    // IBOutlets
    @IBOutlet weak var tableView: UITableView!

    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpTableView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        liveEventTimer?.invalidate()
        liveEventTimer = nil
        liveEventTimer = Timer.scheduledTimer(timeInterval: 15.0,
                                              target: self,
                                              selector: #selector(fetchLiveEvents),
                                              userInfo: nil,
                                              repeats: true)
        fetchContent()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        // Avoid checking for live events when not on home screen
        liveEventTimer?.invalidate()
        liveEventTimer = nil
    }

    // MARK: - Table View
    
    /// All of the necessary table view updates gathered into a single function.
    private func setUpTableView() {
        tableView.dataSource = self
        tableView.delegate = self

        // Register nibs.
        let videoListTableViewCellNib = UINib(nibName: videoListTableViewCell, bundle: .main)
        tableView.register(videoListTableViewCellNib, forCellReuseIdentifier: videoListTableViewCell)

        // Both of these "insets to safe area" settings are required to make sure content goes full width.
        // `insetsContentViewsToSafeArea` could be set in Interface Builder (where it remains true), but
        // is done here in code instead (overriding the Interface Builder setting) to make the relationship between both settings clearer.
        tableView.insetsContentViewsToSafeArea = false
        tableView.insetsLayoutMarginsFromSafeArea = false
    }

    // swiftlint:disable cyclomatic_complexity
    /// Determines the type of a row based on a given index.
    /// - Parameter index:  The index to determine the row type for.
    /// - Returns: The type of the row.
    private func rowType(for index: Int) -> RowType? {
        switch index {
        case 0:
            // For Hero row
            guard let sectionListItem = sectionList?[index],
                  let sectionListId = sectionListItem.id?.dropFirst() else {
                return nil
            }
            return .heroRow(info: (alias: String(sectionListId), title: sectionListItem.title))
        case 1:
            // If live videos exists, index 1 is for live videos. If it does not
            // exist, but continue watching does, index 1 is for continue watching. Otherwise,
            // if neither exist, index 1 is just for normal content.
            if !liveVideos.isEmpty {
                return .liveEvent
            } else if !continueWatchingVideos.isEmpty {
                return .continueWatching
            } else {
                guard let sectionListItem = sectionList?[index],
                      let sectionListId = sectionListItem.id?.dropFirst() else {
                    return nil
                }
                return .videoContent(info: (alias: String(sectionListId), title: sectionListItem.title))
            }
        case 2:
            // If both live videos and continue watching videos exist,
            // live videos is index 1 and continue watching is index 2. Otherwise,
            // if only one of the two rows exist, index 2 is just normal content.
            var moddedIndex = index
            if !liveVideos.isEmpty && !continueWatchingVideos.isEmpty {
                return .continueWatching
            } else if continueWatchingVideos.isEmpty && liveVideos.isEmpty {
                // neither exist
                moddedIndex = index
            } else {
                // at least one exists
                moddedIndex = index - 1
            }
            guard let sectionListItem = sectionList?[moddedIndex],
                  let sectionListId = sectionListItem.id?.dropFirst() else {
                return nil
            }
            return .videoContent(info: (alias: String(sectionListId), title: sectionListItem.title))
        default:
            // Handles non signifcant rows
            var moddedIndex = index
            
            if continueWatchingVideos.isEmpty && liveVideos.isEmpty {
                moddedIndex = index
            } else if !continueWatchingVideos.isEmpty && !liveVideos.isEmpty {
                moddedIndex = index - 2
            } else {
                moddedIndex = index - 1
            }
            
            guard let sectionListItem = sectionList?[moddedIndex],
                  let sectionListId = sectionListItem.id?.dropFirst() else {
                return nil
            }
            return .videoContent(info: (alias: String(sectionListId), title: sectionListItem.title))
        }
    }
    // swiftlint:enable cyclomatic_complexity
    
    /// Given the row type, this returns the corresponding list of content.
    /// - Parameter type: The type of the row to return content for.
    /// - Returns: The content list for the given row type.
    private func dataForRow(type: RowType) -> [VideoListItem]? {
        switch type {
        case .heroRow(let info):
            // First item in content lists
            guard let heroRowList = contentLists?.first(where: {$0.alias == info.alias})?.contentList else {
                return nil
            }
            return heroRowList
        case .liveEvent:
            return liveVideos
        case .continueWatching:
            return continueWatchingVideos
        case .videoContent(let info):
            guard let videoContentList = contentLists?.first(where: {$0.alias == info.alias})?.contentList else {
                return nil
            }
            return videoContentList
        }
    }

    // MARK: - Convenience Methods

    func injectPreloadedContent(sectionList: SectionList?, contentLists: [ContentListCollection]?, liveVideos: [LiveEvent]?) {
        self.sectionList = sectionList
        self.contentLists = contentLists
        self.liveVideos = liveVideos ?? []
    }
    
    private func fetchContent() {
        Task {
            do {
                let fetchedSectionList = try await ContentProvider
                    .fetchSectionList(siteHierarchy: Constants.ContentConfig.siteHierarchyName)
                sectionList = fetchedSectionList
                contentLists?.removeAll()
                liveVideos.removeAll()
                for sectionListElement in fetchedSectionList {
                    guard let sectionListID = sectionListElement.id?.dropFirst() else {
                        Self.logger.error("Failed to get section list ID while fetching content.")
                        continue
                    }
                    let id = String(sectionListID)
                    let contentList = try await ContentProvider.fetchCollection(alias: id)
                    contentLists?.removeAll(where: {$0.alias == id})
                    contentLists?.append((alias: id, contentList: contentList))
                }
                liveVideos = try await ContentProvider.fetchLiveVideos()
                continueWatchingVideos = try ContentProvider.fetchRecentlyWatchedVideos()
                tableView.reloadData()
            } catch {
                let errorMessage = "\(UserFacingStrings.defaultContentFetchErrorMessage) \(error.localizedDescription)."
                Self.logger.error("\(errorMessage)")
                presentErrorAlert(message: errorMessage)
            }
        }
    }

    @objc private func fetchLiveEvents() {
        Task {
            do {
                let refreshedLiveEvents = try await ContentProvider.fetchLiveVideos()
                guard let displayedLiveEvents = liveVideos as? [LiveEvent],
                      !(refreshedLiveEvents.isEmpty && displayedLiveEvents.isEmpty),
                      !displayedLiveEvents.equals(array: refreshedLiveEvents) else {
                          return
                      }
                liveVideos = refreshedLiveEvents
                tableView.beginUpdates()
                if let videoListRowCell = tableView.cellForRow(at: IndexPath(row: liveEventsRowIndex,
                                                                             section: 0)) as? VideoListTableViewCell,
                   videoListRowCell.isLiveRow {
                    if refreshedLiveEvents.isEmpty {
                        tableView.deleteRows(at: [IndexPath(row: liveEventsRowIndex, section: 0)], with: .fade)
                    } else {
                        tableView.reloadRows(at: [IndexPath(row: liveEventsRowIndex, section: 0)], with: .automatic)
                    }
                } else {
                    tableView.insertRows(at: [IndexPath(row: liveEventsRowIndex, section: 0)], with: .automatic)
                }
                tableView.endUpdates()
            } catch {
                let errorMessage = "\(UserFacingStrings.liveEventFetchError) \(error.localizedDescription)."
                Self.logger.error("\(errorMessage)")
                presentErrorAlert(message: errorMessage)
            }
        }
    }
}

// MARK: - Table View

extension HomeViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var rows = 0
        if let sectionList = sectionList {
            rows += sectionList.count
        }
        
        if !liveVideos.isEmpty {
            rows += 1
        }
        
        if !continueWatchingVideos.isEmpty {
            rows += 1
        }
        return rows
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let index = indexPath.row
        guard let videoListRowCell = tableView.dequeueReusableCell(withIdentifier: videoListTableViewCell) as? VideoListTableViewCell,
              let rowType = rowType(for: index) else {
            Self.logger.error("\(UserFacingStrings.cellUIError)")
            return .errorCell(message: UserFacingStrings.cellUIError)
        }
        
        videoListRowCell.delegate = self
        videoListRowCell.prepareForReuse()
        videoListRowCell.collectionView.reloadData()
        
        var listName: String?
        var displayHeroRow = false
        var isContinueWatchingRow = false
        let videoList = dataForRow(type: rowType)
        
        switch rowType {
        case .heroRow(let info):
            videoListRowCell.isLiveRow = false
            displayHeroRow = true
            listName = info.title
        case .liveEvent:
            videoListRowCell.isLiveRow = true
            listName = UserFacingStrings.liveEvent
        case .continueWatching:
            videoListRowCell.isLiveRow = false
            listName = UserFacingStrings.continueWatching
            isContinueWatchingRow = true
        case .videoContent(let info):
            videoListRowCell.isLiveRow = false
            listName = info.title
        }
        
        videoListRowCell.configure(videoList: videoList,
                                   listName: listName,
                                   displayHeroSection: displayHeroRow, isContinueWatchingRow: isContinueWatchingRow)
        return videoListRowCell
    }

    func tableView(_ tableView: UITableView, canFocusRowAt indexPath: IndexPath) -> Bool {
        return false
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return indexPath.row == 0 ? 775 : 350
    }
}

// MARK: - VideoListTableViewCellDelegate

extension HomeViewController: VideoListTableViewCellDelegate {

    func didSelectVideo(videoDetail: VideoDetail, from videoList: [VideoListItem]?) {
        // If live video, launch the player from homescreen
        if videoDetail is LiveEvent {
            let videoPlayerViewController = VideoPlayerViewController.instantiate(videoDetail: videoDetail)
            present(videoPlayerViewController, animated: false)
        } else {
            let videoDetailViewController = VideoDetailViewController.instantiate() as VideoDetailViewController
            videoDetailViewController.configure(videoDetail: videoDetail, relatedVideos: videoList)
            present(videoDetailViewController, animated: true)
        }
    }
}
