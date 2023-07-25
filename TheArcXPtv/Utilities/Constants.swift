//
//  Constants.swift
//  TheArcXP
//
//  Created by Cassandra Balbuena on 3/18/22.
//  Copyright © 2022 Arc XP. All rights reserved.
//

import Foundation

struct Constants {
    struct ContentConfig {
        static let siteName = "arcsales"
        static let orgName = "arcsales"
        static let env = "sandbox"
        static let contentDomain = "arcsales-arcsales-sandbox.web.arc-cdn.net"
        static let siteHierarchyName = "mobile-tv"
    }
    
    struct ImageName {
        static let errorImage = "exclamationmark.triangle.fill"
        static let play = "play.fill"
        static let restart = "backward.end.fill"
    }
    
    static let termsOfServiceANSId = "SN5TD3H2FRD3BLG22KYULN3ICQ"
    static let privacyPolicyANSId = "VOMHFEWMKFDS7NUFFKBXQLUS5E"
    static let bundleIdentifier = Bundle.main.bundleIdentifier ?? "com.washingtonpost.arc.TheArcXPtv"
    static let mainStoryboardName = "Main"
}
