//
//  ArcXPSdkManager.swift
//  TheArcXPtv
//
//  Created by Mahesh Venkateswarlu on 9/20/22.
//  Copyright © 2022 Arc XP. All rights reserved.
//

import Foundation
import os
import ArcXP

/// Handles interfacing with the the ArcXP Content SDK, and video SDK including fetching content, and handling cache parsing when necessary.
struct ContentProvider {

    static let logger = Logger(subsystem: Constants.bundleIdentifier, category: String(describing: Self.self))

    /// Cache time, specified in number of minutes.
    static private let cacheTime: Double = 10

    /// Configure Arc XP Content and Video SDKs for fetching content.
    static func configureArcXPSDKs() {

        let contentConfiguration = ContentConfiguration(baseUrl: "https://\(Constants.ContentConfig.contentDomain)",
                                                        organization: Constants.ContentConfig.orgName,
                                                        environment: .sandbox,
                                                        site: Constants.ContentConfig.siteName,
                                                        thumborResizerKey: "thumbor",
                                                        cacheConfiguration: ArcXPCacheConfig(timeToConsider: 10))
        
        let videoConfiguration = VideoConfiguration(organization: Constants.ContentConfig.orgName,
                                                    environment: .sandbox,
                                                    useGeorestrictions: false)

        Services.configure(service: .content(contentConfiguration))
        Services.configure(service: .video(videoConfiguration))
    }
    
    // MARK: ContentSDK
    
    /// Get list of menu items from ContentSDK
    /// - Parameters:
    ///   - siteHierarchy: Defines the specific site hierarchy for which section list should be retrieved.
    /// - returns: A list of section list elements.
    static func fetchSectionList(siteHierarchy: String) async throws -> SectionList {
        return try await withCheckedThrowingContinuation { continuation in

            ArcXPContentManager.client.getSectionList(siteHierarchy: Constants.ContentConfig.siteHierarchyName) { result in
                switch result {

                case .success(let sectionList):
                    continuation.resume(with: .success(sectionList))

                case .failure(let error):
                    // Check if the network is unavailable. If so, return the provided cache parameter.
                    if let contentError = error as? NetworkError {
                        if case let .URLRequestError(reason) = contentError {
                            if case let .networkUnavailable(cachedContent) = reason {
                                if let sectionList = cachedContent as? SectionList {
                                    continuation.resume(with: .success(sectionList))
                                    return
                                }
                            }
                        }
                    }
                    
                    // Not an unavailable network error. Surface error to caller.
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    /// Fetch the collection associated with the provided `alias` parameter.
    /// - Parameters:
    ///   - alias: Defines the specific collection that should be fetched.
    ///   - index: Index of the search results (Ex: (0..9) -> index = 0, (10..20) -> index = 10)
    /// - returns: A list of content objects.
    static func fetchCollection(alias: String, index: Int = 0) async throws -> ArcXPContentList {
        return try await withCheckedThrowingContinuation { continuation in

            ArcXPContentManager.client.getCollection(alias: alias, index: index) { result in
                switch result {

                case .success(let contentList):
                    continuation.resume(with: .success(contentList))

                case .failure(let error):
                    // Check if the network is unavailable. If so, use the provided cached content.
                    if let contentError = error as? NetworkError {
                        if case let .URLRequestError(reason) = contentError {
                            if case let .networkUnavailable(cachedContent) = reason {
                                if let cachedCollectionList = cachedContent as? ArcXPContentList {
                                    continuation.resume(with: .success(cachedCollectionList))
                                    return
                                }
                            }
                        }
                    }

                    // Not an unavailable network error. Surface the error to the caller.
                    continuation.resume(throwing: error)
                }
            }
        }
    }

    /// Fetch the content lists associated with the provided section list parameter.
    /// - parameter sectionList: The section list containing references for the content lists to be fetched.
    /// - returns: A collection of content lists associated with the provided section list parameter.
    static func fetchContentLists(sectionList: SectionList) async throws -> [ContentListCollection] {
        var contentLists = [ContentListCollection]()
        for sectionListElement in sectionList {
            guard let sectionListID = sectionListElement.id?.dropFirst() else {
                Self.logger.error("Failed to get section list ID while fetching content.")
                continue
            }
            let id = String(sectionListID)
            let contentList = try await ContentProvider.fetchCollection(alias: id)
            contentLists.append((id, contentList))
        }
        return contentLists
    }

    /// Fetch a specific story for the provided identifier.
    /// - parameter id: The identifier for the story that should be fetched.
    /// - returns: The specific content object for the story that is being fetched.
    static func fetchStory(id: String) async throws -> ArcXPContent {
        return try await withCheckedThrowingContinuation { continuation in
            ArcXPContentManager.client.getStoryContent(identifier: id) { result in
                continuation.resume(with: result)
            }
        }
    }

    /// Fetch a collection of videos with the provided keyword(s).
    ///  - parameter keywords: An array of`String` objects that are keywords
    ///  - parameter index: Index of the search results (Ex: (0..9) -> index = 0, (10..20) -> index = 10)
    ///  - parameter size: Size of the results to return
    ///  - parameter completion: The completion handler to call when the request is complete.
    ///   It contains the `Result` type with an array of content data objects ``ArcXPContent``
    static func searchVideos(for keywords: [String],
                             index: Int = 0,
                             size: Int = 20,
                             completion: @escaping ArcXPCollectionResultHandler) {
        ArcXPContentManager.client.searchVideos(by: keywords, index: index, size: size) { result in completion(result) }
    }
    
    /// Fetch the collection of videos that have been recently watched by the user.
    /// - Returns: The list of recently watched videos. It can be empty if no videos have been watched recently.
    static func fetchRecentlyWatchedVideos() throws -> [CacheableVideo] {
        var videos = [CacheableVideo]()
        guard let recentlyWatchedVideos = try CacheManager.getAllCachedVideos() as? [CacheableVideo] else {
            throw CacheError.retrievalError("Error retrieving cached content.")
        }
        
        if recentlyWatchedVideos.isEmpty {
            return videos
        }
        
        videos = recentlyWatchedVideos.filter({ video in
            guard let resumeTime = video.cachedPlayData?.resumeTime, let length = video.cachedPlayData?.length else {
                // If either or both properties are nil, this means that the video has not been recently watched
                // or data to categorize it as such does not exist.
                return false
            }
            
            if video.isLiveVideo { return false }
            return (resumeTime < length && resumeTime > 0.0)
        })
        return videos
    }
    
    // MARK: - Video SDK
    
    /// Find the current live events in the organization
    /// - Parameter completion: A block that takes a `Result` object that
    ///     will contain the list of live events (if found), or any error if any of the
    static func fetchLiveVideos() async throws -> [LiveEvent] {
        return try await withCheckedThrowingContinuation { continuation in
            ArcMediaClientManager.client.findLiveEvents { liveVideoEventsResult in
                continuation.resume(with: liveVideoEventsResult)
            }
        }
    }
}
