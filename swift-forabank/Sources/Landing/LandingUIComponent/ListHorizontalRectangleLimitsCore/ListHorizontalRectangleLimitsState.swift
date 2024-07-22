//
//  ListHorizontalRectangleLimitsState.swift
//  
//
//  Created by Andryusina Nataly on 21.06.2024.
//

import Foundation

public struct ListHorizontalRectangleLimitsState: Equatable {
    
    let id: UUID
    let list: UILanding.List.HorizontalRectangleLimits
    var limitsLoadingStatus: LimitsLoadingStatus
    
    public init(
        id: UUID = UUID(),
        list: UILanding.List.HorizontalRectangleLimits,
        limitsLoadingStatus: LimitsLoadingStatus
    ) {
        self.id = id
        self.list = list
        self.limitsLoadingStatus = limitsLoadingStatus
    }
}
