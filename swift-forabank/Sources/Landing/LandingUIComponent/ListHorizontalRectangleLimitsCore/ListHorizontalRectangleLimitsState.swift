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
    var destination: Destination?

    public init(
        id: UUID = UUID(),
        list: UILanding.List.HorizontalRectangleLimits,
        limitsLoadingStatus: LimitsLoadingStatus,
        destination: Destination? = nil
    ) {
        self.id = id
        self.list = list
        self.limitsLoadingStatus = limitsLoadingStatus
        self.destination = destination
    }
}

public extension ListHorizontalRectangleLimitsState {
    
    enum Destination: Identifiable, Equatable {
        
        public static func == (lhs: ListHorizontalRectangleLimitsState.Destination, rhs: ListHorizontalRectangleLimitsState.Destination) -> Bool {
            return lhs.id == rhs.id
        }
        
        case settingsView(LandingWrapperViewModel, String)

        public var id: _Case { _case }
        
        public var _case: _Case {
            
            switch self {
            case .settingsView: return .settingsView
            }
        }
        
        public enum _Case {
            
            case settingsView
        }
        
        var viewModel: LandingWrapperViewModel {
            switch self {
            case let .settingsView(landingWrapperViewModel, _):
                return landingWrapperViewModel
            }
        }
    }
}


