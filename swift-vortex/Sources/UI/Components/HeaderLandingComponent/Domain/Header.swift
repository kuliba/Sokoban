//
//  Header.swift
//
//
//  Created by Дмитрий Савушкин on 21.02.2025.
//

import Foundation

public struct Header {
    
    public let title: String
    public let navTitle: String
    public let navSubtitle: String
    public let options: [String]
    public let imageUrl: String?
    
    public init(
        title: String,
        navTitle: String,
        navSubtitle: String,
        options: [String],
        imageUrl: String?
    ) {
        self.title = title
        self.navTitle = navTitle
        self.navSubtitle = navSubtitle
        self.options = options
        self.imageUrl = imageUrl
    }
}
