//
//  CacheManager.swift
//  TheArcXPtv
//
//  Created by David Seitz Jr on 11/8/22.
//  Copyright © 2022 Arc XP. All rights reserved.
//

import Foundation
import os

enum CacheError: Error {
    case retrievalError(String)
}

struct CacheManager {
    static let logger = Logger(subsystem: Constants.bundleIdentifier, category: String(describing: Self.self))

    static func cache(videos: [VideoDetail]) throws {
        try CoreDataController.save(videoDetails: videos)
    }

    static func getAllCachedVideos() throws -> [VideoDetail]? {
        return try CoreDataController.getSavedVideos()
    }

    static func getCachedVideo(with videoID: String) throws -> VideoDetail? {
        return try CoreDataController.getSavedVideo(with: videoID)
    }

    static func clearVideoCache() throws {
        try CoreDataController.deleteAllVidoes()
    }
}
