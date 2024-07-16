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
    
    public init(
        list: UILanding.List.HorizontalRectangleLimits,
        limitsLoadingStatus: LimitsLoadingStatus
    ) {
        self.list = list
        self.limitsLoadingStatus = limitsLoadingStatus
    }
}
