//
//  VideoDetail.swift
//  TheArcXPtv
//
//  Created by David Seitz Jr on 10/25/22.
//  Copyright © 2022 Arc XP. All rights reserved.
//

import UIKit

/// An abstraction for video details that makes accessing regular data simple, consistent, and safe from exposing more data than needed.
protocol VideoDetail: VideoListItem {
    typealias CachedPlayData = (lastPlayedDate: Date, resumeTime: Double, length: Double)
    var videoDescription: String? { get }
    var formattedPublishDate: String? { get }
    var credit: String? { get }
    var cachedPlayData: CachedPlayData? { get }
    var isLiveVideo: Bool { get }

    // TODO: AM-5216 - Update `ArcXPContent` to make length/duration available
    // var length: String? { get }
}
