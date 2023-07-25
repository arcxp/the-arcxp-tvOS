//
//  DataController.swift
//  TheArcXPtv
//
//  Created by David Seitz Jr on 11/24/22.
//  Copyright © 2022 Arc XP. All rights reserved.
//

import CoreData
import os

class CoreDataController: ObservableObject {
    private static let logger = Logger(subsystem: Constants.bundleIdentifier, category: String(describing: CoreDataController.self))
    private static let container = NSPersistentContainer(name: "TheArcXPTV")
    private static let cacheableVideoEntityName = "CacheableVideo"
    
    // MARK: - General CoreData handling
    
    static func setUp() {
        container.loadPersistentStores { _, error in
            if let error = error {
                logger.error("Failed to load persistent stores. Error: \(error.localizedDescription)")
            }
        }
    }
    
    private static func saveContext() {
        do {
            try container.viewContext.save()
        } catch {
            logger.error("Failed to save context. Error: \(error.localizedDescription)")
        }
    }
    
    // MARK: - CoreData CRUD functions
    
    static func save(videoDetails: [VideoDetail]) throws {
        for videoDetail in videoDetails {
            // If this video has already been cached, fetch the cached video for update.
            var existingCacheableVideo: CacheableVideo?
            if let videoID = videoDetail.id,
               let savedVideo = try getSavedVideo(with: videoID) as? CacheableVideo {
                existingCacheableVideo = savedVideo
            }
            
            let cacheableVideo = existingCacheableVideo ?? CacheableVideo(context: container.viewContext)
            cacheableVideo.id = videoDetail.id
            cacheableVideo.videoDescription = videoDetail.videoDescription
            cacheableVideo.publishDate = videoDetail.formattedPublishDate
            cacheableVideo.credit = videoDetail.credit
            cacheableVideo.lastPlayedDate = videoDetail.cachedPlayData?.lastPlayedDate
            cacheableVideo.title = videoDetail.title
            cacheableVideo.imageUrlString = videoDetail.imageUrlString
            cacheableVideo.isLiveVideo = videoDetail.isLiveVideo
            if let resumeTime = videoDetail.cachedPlayData?.resumeTime { cacheableVideo.resumeTime = resumeTime }
            if let length = videoDetail.cachedPlayData?.length { cacheableVideo.length = length }
        }
        
        saveContext()
    }
    
    static func getSavedVideos() throws -> [VideoDetail]? {
        let fetchRequest = NSFetchRequest<CacheableVideo>(entityName: cacheableVideoEntityName)
        return try container.viewContext.fetch(fetchRequest)
    }
    
    static func getSavedVideo(with id: String) throws -> VideoDetail? {
        let fetchRequest = NSFetchRequest<CacheableVideo>(entityName: cacheableVideoEntityName)
        fetchRequest.predicate = NSPredicate(format: "%K == %@", argumentArray: ["id", id])
        let results = try container.viewContext.fetch(fetchRequest)
        return results.first
    }
    
    static func deleteAllVidoes() throws {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: cacheableVideoEntityName)
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        try container.viewContext.execute(deleteRequest)
    }
}

// MARK: - Conform CacheableVideo to VideoDetail

extension CacheableVideo: VideoDetail {
    var formattedPublishDate: String? { publishDate }
    var cachedPlayData: CachedPlayData? { (lastPlayedDate, resumeTime, length) as? CachedPlayData }
}
