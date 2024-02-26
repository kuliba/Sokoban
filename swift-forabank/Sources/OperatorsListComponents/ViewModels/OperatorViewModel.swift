//
//  File.swift
//  
//
//  Created by Дмитрий Савушкин on 09.02.2024.
//

import Foundation

public struct OperatorViewModel {
    
    public let icon: Data
    public let title: String
    public let description: String?
    
    public init(
        icon: Data,
        title: String,
        description: String?
    ) {
        self.icon = icon
        self.title = title
        self.description = description
    }
}
