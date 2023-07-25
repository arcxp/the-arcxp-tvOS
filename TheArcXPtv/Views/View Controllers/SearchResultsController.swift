//
//  SearchResultsController.swift
//  TheArcXPtv
//
//  Created by Cassandra Balbuena on 9/19/22.
//  Copyright © 2022 Arc XP. All rights reserved.
//

import UIKit
import ArcXP
import os

class SearchResultsController: UICollectionViewController {
    private static let logger = Logger(subsystem: Constants.bundleIdentifier,
                                       category: String(describing: SearchResultsController.self))
    // Constants
    private let videoListCollectionViewCell = "VideoListCollectionViewCell"
    private let collectionViewInterItemMinimumSpacing: CGFloat = 20
    private let collectionViewCellMinimumSpacing: CGFloat = 50
    private let collectionViewCellWidth = 325
    private let collectionViewCellHeight = 280

    // Properties
    private var videoSearchResults = ArcXPContentList() {
        didSet {
            collectionView?.reloadData()
        }
    }
    private var searchText = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let collectionViewCellNib = UINib(nibName: videoListCollectionViewCell, bundle: .main)
        collectionView.register(collectionViewCellNib, forCellWithReuseIdentifier: videoListCollectionViewCell)
        collectionView.backgroundColor = .clear
        collectionView.clipsToBounds = false
    }
    
    static func setUpSearch(storyboard: UIStoryboard?) -> UISearchContainerViewController {
        let searchResultsController = SearchResultsController(collectionViewLayout: UICollectionViewFlowLayout())
        let searchController = UISearchController(searchResultsController: searchResultsController)
        searchController.searchResultsUpdater = searchResultsController
        
        let searchContainer = UISearchContainerViewController(searchController: searchController)
        searchContainer.title = UserFacingStrings.search
        return searchContainer
    }

    // MARK: - UICollectionViewController

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return videoSearchResults.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let videoCell = collectionView.dequeueReusableCell(withReuseIdentifier: videoListCollectionViewCell,
                                                                 for: indexPath) as? VideoListCollectionViewCell else {
            Self.logger.error("\(UserFacingStrings.cellUIError)")
            presentErrorAlert(message: UserFacingStrings.cellUIError)
            return UICollectionViewCell()
        }

        videoCell.configure(with: videoSearchResults[indexPath.row])
        return videoCell
    }

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let mainStoryBoard = UIStoryboard(name: "Main", bundle: .main)
        guard let videoDetailViewController = mainStoryBoard.instantiateViewController(
            withIdentifier: "VideoDetailViewController") as? VideoDetailViewController else {
            Self.logger.error("\(UserFacingStrings.vcLoadError)")
            presentErrorAlert(message: UserFacingStrings.vcLoadError)
                return
            }
        videoDetailViewController.configure(videoDetail: videoSearchResults[indexPath.row],
                                            relatedVideos: videoSearchResults as [VideoListItem])
        present(videoDetailViewController, animated: true)
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension SearchResultsController: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return collectionViewCellMinimumSpacing
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return collectionViewInterItemMinimumSpacing
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionViewCellWidth, height: collectionViewCellHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 30, bottom: 0, right: 30)
    }
}

// MARK: - UISearchResultsUpdating

extension SearchResultsController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        guard let text = searchController.searchBar.text, !text.isEmpty else {
            videoSearchResults = []
            return
        }
        
        // Prevents multiple searches for the same input text
        if searchText == text {
            return
        }
        
        ContentProvider.searchVideos(for: [text]) { [weak self] searchResults in
            self?.searchText = text
            switch searchResults {
            case .success(let contentList):
                if !contentList.isEmpty {
                    self?.videoSearchResults = contentList
                }
            case .failure(let error):
                searchController.searchBar.text = ""
                self?.presentErrorAlert(message: error.localizedDescription)
            }
        }
    }
}
