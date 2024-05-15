//
//  SberOperator.swift
//
//
//  Created by Дмитрий Савушкин on 14.02.2024.
//

import Foundation

public struct SberOperator: Identifiable, Equatable {
    
    public let id: String
    public let inn: String?
    public let md5Hash: String?
    public let title: String
    
    public init(
        id: String,
        inn: String?,
        md5Hash: String?,
        title: String
    ) {
        self.id = id
        self.inn = inn
        self.md5Hash = md5Hash
        self.title = title
    }
}
