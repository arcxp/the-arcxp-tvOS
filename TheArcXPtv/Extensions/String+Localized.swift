//
//  String+Localized.swift
//  TheArcXPtv
//
//  Created by Cassandra Balbuena on 2/2/23.
//  Copyright © 2023 Arc XP. All rights reserved.
//

import Foundation

extension String {

    func localized(withComment comment: String? = nil) -> String {
        return NSLocalizedString(self, comment: comment ?? "")
    }

}
