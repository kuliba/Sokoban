//
//  SberOperator.swift
//
//
//  Created by Дмитрий Савушкин on 14.02.2024.
//

import Foundation

public struct SberOperator: Equatable {
    
    public let icon: String?
    public let inn: String?
    public let title: String
    
    public init(
        icon: String?,
        inn: String?,
        title: String
    ) {
        self.icon = icon
        self.inn = inn
        self.title = title
    }
}

extension SberOperator: Identifiable {
    
    public var id: String { title }
}
