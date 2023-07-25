//
//  BundleExtension.swift
//  TheArcXPtv
//
//  Created by Cassandra Balbuena on 11/1/22.
//  Copyright © 2022 Arc XP. All rights reserved.
//

import Foundation
import os

extension Bundle {
    private static let logger = Logger(subsystem: Constants.bundleIdentifier,
                                       category: String(describing: Bundle.self))
    public var appName: String { getInfo("CFBundleName") }
    public var displayName: String {getInfo("CFBundleDisplayName")}
    public var language: String {getInfo("CFBundleDevelopmentRegion")}
    public var identifier: String {getInfo("CFBundleIdentifier")}
    public var copyright: String {getInfo("NSHumanReadableCopyright").replacingOccurrences(of: "\\\\n", with: "\n") }
    
    public var appBuild: String { getInfo("CFBundleVersion") }
    public var appVersionLong: String { getInfo("CFBundleShortVersionString") }
    
    fileprivate func getInfo(_ str: String) -> String {
        guard let infoStr = infoDictionary?[str] as? String else {
            Self.logger.error("Error getting application information.")
            return ""
        }
        return infoStr
    }
}
