//
//  ArcXPSdkManager.swift
//  TheArcXPtv
//
//  Created by Mahesh Venkateswarlu on 9/20/22.
//  Copyright © 2022 Arc XP. All rights reserved.
//

import Foundation
import ArcXPContentSDK
import ArcXPVideo

struct ArcXPSdkManager {
    
    static func initializeArcXPSdk() {
        // Initialize ContentSDK
        let contentConfiguration = ArcXPContentConfig(organizationName: Constants.Org.orgName,
                                                      serverEnvironment: .sandbox,
                                                      site: Constants.Org.siteName,
                                                      hostDomain: Constants.Org.contentDomain)
        ArcXPContentManager.setUp(with: contentConfiguration, cacheConfig: ArcXPCacheConfig(timeToConsider: 10)) // 10 mins cache time
        
        // Initialize VideoSDK
        ArcMediaClientManager.client = ArcMediaRealClient(organizationID: Constants.Org.orgName,
                                                          serverEnvironment: .sandbox,
                                                          useGeoRestrictions: false)
    }
    
    /// Get list of menu items from ContentSDK
    /// - Parameter siteHierarchy: `String`
    /// - Parameter completion: List of section front elements `[SectionListElement]`
    static func getMenuItems(siteHierarchy: String, completion: @escaping ArcXPSectionListHandler) {
        ArcXPContentManager.client.getSectionList(siteHierarchy: Constants.Org.siteHierarchyName) { result in
            completion(result)
        }
    }
    
    /// Get the collectins results for the given `alias`
    /// - Parameters:
    ///     /// - Parameters:
    ///   - alias: A `String` object that brings down a feeds collection
    ///   - index: Index of the search results (Ex: (0..9) -> index = 0, (10..20) -> index = 10)
    ///   - size: size of the collections result
    ///   - handleResult: completion:
    static func fetchCollection(alias: String,
                                index: Int = 0,
                                completion: @escaping ArcXPCollectionResultHandler) {
        ArcXPContentManager.client.getCollection(alias: alias, index: index) { result in
            completion(result)
        }
    }
    
    static func fetchStory(id: String, completion: @escaping ArcXPStoryResultHandler) {
        ArcXPContentManager.client.getStoryContent(identifier: id) { result in
            completion(result)
        }
    }
    
    static func search(for keywords: [String], index: Int = 0, size: Int = 20, completion: @escaping ArcXPCollectionResultHandler) {
        ArcXPContentManager.client.search(by: keywords, index: index, size: size) { result in
            switch result {
            case .success(let searchResults):
                completion(.success(searchResults))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
