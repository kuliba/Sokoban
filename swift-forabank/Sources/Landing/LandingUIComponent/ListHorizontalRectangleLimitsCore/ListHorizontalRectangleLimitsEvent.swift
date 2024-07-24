//
//  ListHorizontalRectangleLimitsEvent.swift
//  
//
//  Created by Andryusina Nataly on 21.06.2024.
//

import Foundation

public enum ListHorizontalRectangleLimitsEvent: Equatable {
    
    public static func == (lhs: ListHorizontalRectangleLimitsEvent, rhs: ListHorizontalRectangleLimitsEvent) -> Bool {
        lhs.id == rhs.id
    }
        
    case buttonTapped(Info)
    case dismissDestination
    case loadedLimits(LandingWrapperViewModel?, String)
    case updateLimits(SVCardLimitsResult)
    case saveLimits([BlockHorizontalRectangularEvent.Limit])
    case delayAlert(String)
    case informer(String)
    
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
        case .informer:
            return .informer
        }
    }
    
    public enum Case {
        
        case buttonTapped, dismissDestination, loadedLimits, updateLimits, saveLimits, delayAlert, informer
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
