//
//  File.swift
//  
//
//  Created by Дмитрий Савушкин on 12.02.2024.
//

import Foundation

public struct OperatorData: Equatable {
    
    let name: String
    let inn: String
    let serviceId: String
    let md5hash: String
    
    public init(
        name: String,
        inn: String,
        serviceId: String,
        md5hash: String
    ) {
        self.name = name
        self.inn = inn
        self.serviceId = serviceId
        self.md5hash = md5hash
    }
}
