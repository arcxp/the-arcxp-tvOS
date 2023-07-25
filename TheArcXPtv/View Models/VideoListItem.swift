//
//  VideoListItem.swift
//  TheArcXPtv
//
//  Created by David Seitz Jr on 10/25/22.
//  Copyright © 2022 Arc XP. All rights reserved.
//

import UIKit

/// A view model for consistently accessing video list items, regardless of whether they're VOD, live, or something else.
protocol VideoListItem {
    var id: String? { get }
    var title: String? { get }
    var imageUrlString: String? { get }
}
