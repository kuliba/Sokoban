//
//  LimitsLoadingStatus.swift
//
//
//  Created by Andryusina Nataly on 21.06.2024.
//

import Foundation

public enum LimitsLoadingStatus: Equatable {
    
    case inflight, failure, limits(SVCardLimits)
}
