//
//  LiveEvent.swift
//  TheArcXPtv
//
//  Created by David Seitz Jr on 10/26/22.
//  Copyright © 2022 Arc XP. All rights reserved.
//

import Foundation
import ArcXP

extension LiveEvent: VideoDetail {
    var isLiveVideo: Bool { true }
    var id: String? { contentConfig.uuid }
    var title: String? { contentConfig.title }
    var videoDescription: String? { contentConfig.blurb }
    var formattedPublishDate: String? { Date().formatted(date: .long, time: .omitted) }
    var credit: String? { nil }
    var cachedPlayData: CachedPlayData? { nil }
    var imageUrlString: String? { promoImage.imageUrl?.absoluteString }
}

extension Array where Iterator.Element == LiveEvent {
    /// Compares two `LiveEvent` array objects
    /// - Parameter array2: list of `LiveEvent`
    /// - Returns: `Bool` result of the comparision
    func equals(array: [LiveEvent]) -> Bool {
        if self.count != array.count {
            return false
        }
        for index in 0...array.count - 1  where self[index] != array[index] {
            return false
        }
        return true
    }
}

extension LiveEvent: Equatable {
    public static func == (lhs: LiveEvent, rhs: LiveEvent) -> Bool {
        return (lhs.id == rhs.id &&
                lhs.title == rhs.title &&
                lhs.videoDescription == rhs.videoDescription &&
                lhs.imageUrlString == rhs.imageUrlString &&
                lhs.formattedPublishDate == rhs.formattedPublishDate &&
                lhs.credit == rhs.credit &&
                lhs.isLiveVideo == rhs.isLiveVideo)
    }
}
