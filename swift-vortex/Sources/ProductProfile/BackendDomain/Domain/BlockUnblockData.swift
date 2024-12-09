//
//  BlockUnblockData.swift
//
//
//  Created by Andryusina Nataly on 12.02.2024.
//

public struct BlockUnblockData: Equatable {
    
    let statusBrief: String
    let statusDescription: String
    
    public init(
        statusBrief: String,
        statusDescription: String
    ) {
        self.statusBrief = statusBrief
        self.statusDescription = statusDescription
    }
}
