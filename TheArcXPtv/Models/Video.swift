//
//  Video.swift
//  TheArcXPtv
//
//  Created by David Seitz Jr on 9/7/22.
//  Copyright © 2022 Arc XP. All rights reserved.
//

import AVKit

/// A container for all data related to videos that may be displayed and viewed within this application.
struct Video: Codable {
    var identifier: String?
    var title: String?
    var description: String?
    var image: String?
    var publishDate: String?
    var credit: String?
    let resumeTime: Double?
    let length: Double?
    var lastViewedTime: Date?
    var isLiveEvent: Bool?

    init(videoDetail: VideoDetail, resumeTime: Double? = nil, length: Double? = nil, lastViewedTime: Date? = nil) {
        identifier = videoDetail.id ?? ""
        title = videoDetail.title ?? ""
        description = videoDetail.videoDescription ?? ""
        image = videoDetail.imageUrlString
        publishDate = videoDetail.formattedPublishDate
        credit = videoDetail.credit
        isLiveEvent = videoDetail.isLiveVideo
        self.resumeTime = resumeTime
        self.length = length
        self.lastViewedTime = lastViewedTime
    }
    
    init(identifier: String,
         title: String,
         description: String? = nil,
         image: String? = nil,
         publishDate: String? = nil,
         credit: String? = nil,
         resumeTime: Double? = nil,
         length: Double? = nil,
         lastViewedTime: Date? = nil,
         isLiveEvent: Bool? = nil) {
        self.identifier = identifier
        self.title = title
        self.description = description
        self.image = image
        self.publishDate = publishDate
        self.credit = credit
        self.resumeTime = resumeTime
        self.length = length
        self.lastViewedTime = lastViewedTime
        self.isLiveEvent = isLiveEvent
    }
}

extension Video: VideoDetail {
    var isLiveVideo: Bool { isLiveEvent ?? false }
    var videoDescription: String? { description }
    var formattedPublishDate: String? { publishDate }
    var id: String? { identifier }
    var imageUrlString: String? { image }
    var cachedPlayData: CachedPlayData? {
        guard let lastPlayedDate = lastViewedTime,
              let length = length,
              let resumeTime = resumeTime
        else {
            return nil
        }
        return (lastPlayedDate, resumeTime, length)
    }
}
