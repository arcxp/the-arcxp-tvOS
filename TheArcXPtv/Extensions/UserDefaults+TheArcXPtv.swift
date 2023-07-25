//
//  UserDefaults.swift
//  TheArcXPtv
//
//  Created by Mahesh Venkateswarlu on 10/11/22.
//  Copyright © 2022 Arc XP. All rights reserved.
//

import Foundation
import os

let userDefaults = UserDefaults.standard

protocol ObjectSavable {
    func setObject<T: Encodable>(_ object: T, forKey: String)
    func getObject<T: Decodable>(forKey: String, castTo type: T.Type) -> T?
}

extension UserDefaults: ObjectSavable {

    static let logger = Logger(subsystem: Constants.bundleIdentifier, category: "UserDefaults+ObjectSavable")

    func setObject<T: Encodable>(_ object: T, forKey: String) {
        let encoder = JSONEncoder()
        do {
            let data = try encoder.encode(object)
            set(data, forKey: forKey)
        } catch {
            Self.logger.error("Failed to encode object while saving to UserDefaults.")
        }
    }
    
    func getObject<T: Decodable>(forKey: String, castTo type: T.Type) -> T? {
        guard let data = data(forKey: forKey) else {
            // Object does not exist in user defaults. Gracefully return nil and exit.
            return nil
        }
        let decoder = JSONDecoder()
        do {
            let object = try decoder.decode(type, from: data)
            return object
        } catch {
            Self.logger.error("Failed to decode object from UserDefaults.")
            return nil
        }
    }
}

enum ObjectSavableError: String, LocalizedError {
    case unableToEncode = "Unable to encode object into data"
    case noValue = "No data object found for the given key"
    case unableToDecode = "Unable to decode object into given type"
    
    var errorDescription: String? {
        rawValue
    }
}
