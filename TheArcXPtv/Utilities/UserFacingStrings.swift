//
//  UserFacingStrings.swift
//  TheArcXPtv
//
//  Created by Cassandra Balbuena on 1/27/23.
//  Copyright © 2023 Arc XP. All rights reserved.
//

import Foundation

// swiftlint:disable line_length
public struct UserFacingStrings {
    // Alert related strings.
    static let okAlert = "OK".localized(withComment: "Accept and dismiss alert.")
    static let errorAlert = "Error".localized(withComment: "Title of the error alert.")
    
    // Strings attributed to labels.
    static let home = "Home".localized(withComment: "Home screen of the app.")
    static let search = "Search".localized(withComment: "Search screen of the app.")
    static let settings = "Settings".localized(withComment: "Settings screen of the app.")
    static let play = "Play".localized(withComment: "Start the video.")
    static let resume = "Resume".localized(withComment: "Resume playing the video.")
    static let replay = "Watch Again".localized(withComment: "Play the video again.")
    static let continueWatching = "Continue Watching".localized(withComment: "Title for the continue watching row.")
    static let liveEvent = "Live Videos".localized(withComment: "Title for the live videos row.")
    static let videos = "Videos".localized(withComment: "Default section list title.")
    static let relatedVideos = "Related Videos".localized(withComment: "Title for the row containing related videos.")
    static let tos = "Terms of Service".localized(withComment: "Terms of service string for labels.")
    static let privacyPolicy = "Privacy Policy".localized(withComment: "Privacy Policy string for labels.")
    
    // Error related strings.
    static let defaultContentFetchErrorMessage = "Failed to fetch content with error: ".localized(
        withComment: "Default error message.")
    static let loadingScreenError = "Failed to load destination view controller from loading screen.".localized(
        withComment: "Loading screen error message.")
    static let cellUIError = "Failed to load UI for cell.".localized(withComment: "Cell loading error message.")
    static let vcLoadError = "Failed to load detail view controller. Cannot display selected item.".localized(
        withComment: "View Controller load error.")
    static let tosParseError = "Failed to parse content for Terms of Service.".localized(withComment: "Terms of Service parse error.")
    static let ppParseError = "Failed to parse content for Privacy Policy.".localized(withComment: "Privacy Policy parse error.")
    static let videoDetailError = "Failed to access the video detail while attempting to play video.".localized(
        withComment: "Video detail load error.")
    static let videoCacheError = "There was an error while attempting to cache video data: ".localized(
        withComment: "Video caching error.")
    static let videoLoadError = "Failed to load video.".localized(withComment: "Video load error message.")
    static let liveEventFetchError = "Failed to fetch live content with error: ".localized(
        withComment: "Live event fetch error message.")
}
