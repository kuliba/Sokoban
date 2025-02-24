//
//  Header.swift
//
//
//  Created by Дмитрий Савушкин on 21.02.2025.
//

import Foundation

public struct Header {
    
    let title: String
    let options: [String]
    let md5Hash: String?
    
    public init(
        title: String,
        options: [String],
        md5Hash: String?
    ) {
        self.title = title
        self.options = options
        self.md5Hash = md5Hash
    }
}
