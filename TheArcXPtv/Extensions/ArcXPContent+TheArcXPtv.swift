//
//  ArcXPContent+TheArcXPtv.swift
//  TheArcXPtv
//
//  Created by David Seitz Jr on 10/25/22.
//  Copyright © 2022 Arc XP. All rights reserved.
//

import Foundation
import ArcXP
import os

extension ArcXPContent: VideoDetail {

    private static let logger = Logger(subsystem: Constants.bundleIdentifier, category: String(describing: ArcXPContent.self))
    private static let originalContentDateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"

    var id: String? { identifier }
    var title: String? { headlines?.basic }
    var videoDescription: String? { subheadlines?.basic }
    var imageUrlString: String? { (promoItems?.content as? ImageContentElement)?.url }
    var credit: String? { owner?.name }
    var isLiveVideo: Bool { false }

    var cachedPlayData: CachedPlayData? {
        do {
            if let videoID = id,
               let cachedPlayData = try CacheManager.getCachedVideo(with: videoID)?.cachedPlayData {
                return cachedPlayData
            }
        } catch {
            Self.logger.error("There was an error while reading cachedPlayData. Error: \(error.localizedDescription)")
        }
        // The related cache data does not exist. Gracefully return nil and exit.
        return nil
    }

    var formattedPublishDate: String? {
        guard let originalPublishDateString = publishDate,
              let publishDate = date(from: originalPublishDateString) else {
                  Self.logger.error("Did not format `publishDate` due to a missing `publishDate` value.")
                  return nil
              }
        return publishDate.formatted(date: .long, time: .omitted)
    }

    func date(from dateString: String, format: String = Self.originalContentDateFormat) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        dateFormatter.locale =  Locale(identifier: "en_US_POSIX")
        return dateFormatter.date(from: dateString)
    }
}
