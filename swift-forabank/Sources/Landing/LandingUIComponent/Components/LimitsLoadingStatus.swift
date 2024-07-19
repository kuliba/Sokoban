//
//  LimitsLoadingStatus.swift
//
//
//  Created by Andryusina Nataly on 21.06.2024.
//

import Foundation

public enum LimitsLoadingStatus: Equatable {
    
    case inflight(RequestType), failure, limits(SVCardLimits)
    
    public enum RequestType: Equatable {
        case loadingSVCardLimits
        case loadingSettingsLimits
    }
}
