//
//  ListHorizontalRectangleLimitsEvent.swift
//  
//
//  Created by Andryusina Nataly on 21.06.2024.
//

import Foundation
import SVCardLimitAPI

public enum ListHorizontalRectangleLimitsEvent: Equatable {
    
    public static func == (lhs: ListHorizontalRectangleLimitsEvent, rhs: ListHorizontalRectangleLimitsEvent) -> Bool {
        lhs.id == rhs.id
    }
        
    case buttonTapped(Info)
    case delayAlert(String)
    case dismissDestination
    case informerWithLimits(String, [GetSVCardLimitsResponse.LimitItem])
    case limitChanging([BlockHorizontalRectangularEvent.Limit], Bool)
    case loadedLimits(LandingWrapperViewModel?, String, String)
    case saveLimits([BlockHorizontalRectangularEvent.Limit])
    case showAlert(String)
    case updateLimits(SVCardLimitsResult)
    
    public var id: Case {
        
        switch self {
        
        case .buttonTapped:
            return .buttonTapped
        case .dismissDestination:
            return .dismissDestination
        case .loadedLimits:
            return .loadedLimits
        case .updateLimits:
            return .updateLimits
        case .saveLimits:
            return .saveLimits
        case .delayAlert:
            return .delayAlert
        case .showAlert:
            return .showAlert
        case .informerWithLimits:
            return .informerWithLimits
        case .limitChanging:
            return .limitChanging
        }
    }
    
    public enum Case {
        
        case buttonTapped, dismissDestination, loadedLimits, updateLimits, saveLimits, delayAlert, showAlert, informerWithLimits, limitChanging
    }

    public struct Info: Equatable {
        public let limitType: String
        public let action: String
        
        public init(limitType: String, action: String) {
            self.limitType = limitType
            self.action = action
        }
    }
    
    public enum SVCardLimitsResult: Equatable {
        case failure
        case success(SVCardLimits)
    }
}
