//
//  ListHorizontalRectangleLimitsState.swift
//  
//
//  Created by Andryusina Nataly on 21.06.2024.
//

import Foundation

public struct ListHorizontalRectangleLimitsState: Equatable {
    
    let list: UILanding.List.HorizontalRectangleLimits
    var limitsLoadingStatus: LimitsLoadingStatus
    var event: ListHorizontalRectangleLimitsEvent?
    
    public init(
        list: UILanding.List.HorizontalRectangleLimits,
        limitsLoadingStatus: LimitsLoadingStatus,
        event: ListHorizontalRectangleLimitsEvent? = nil
    ) {
        self.list = list
        self.event = event
        self.limitsLoadingStatus = limitsLoadingStatus
    }
}
