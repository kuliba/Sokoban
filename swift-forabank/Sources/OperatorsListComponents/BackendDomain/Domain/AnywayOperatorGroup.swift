//
//  AnywayOperatorGroup.swift
//
//
//  Created by Дмитрий Савушкин on 14.02.2024.
//

import Foundation

public struct OperatorGroup: Codable, Equatable {
    
    let md5hash: String
    public let title: String
    public let description: String
    
    public init(
        md5hash: String,
        title: String,
        description: String
    ) {
        self.md5hash = md5hash
        self.title = title
        self.description = description
    }
}
