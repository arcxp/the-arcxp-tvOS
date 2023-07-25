//
//  String+HTMLText.swift
//  TheArcXPtv
//
//  Created by Cassandra Balbuena on 11/8/22.
//  Copyright © 2022 Arc XP. All rights reserved.
//

import Foundation

extension String {
    func htmlAttributedString() -> NSAttributedString? {
        let htmlTemplate = """
    <!doctype html>
    <html>
      <head>
        <style>
          body {
            font-family: -apple-system;
            font-size: 30px;
            color: white;
          }
        </style>
      </head>
      <body>
        \(self)
      </body>
    </html>
    """
        guard let data = htmlTemplate.data(using: .utf8), let attributedString = try? NSAttributedString(
            data: data,
            options: [.documentType: NSAttributedString.DocumentType.html,
                      .characterEncoding: String.Encoding.utf8.rawValue],
            documentAttributes: nil) else {
            return nil
        }

        return attributedString
    }
}
