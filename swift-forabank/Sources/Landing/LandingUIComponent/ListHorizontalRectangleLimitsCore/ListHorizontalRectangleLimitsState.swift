//
//  ListHorizontalRectangleLimitsState.swift
//  
//
//  Created by Andryusina Nataly on 21.06.2024.
//

import Foundation
import SwiftUI

public struct ListHorizontalRectangleLimitsState: Equatable {
    
    let id: UUID
    let list: UILanding.List.HorizontalRectangleLimits
    var limitsLoadingStatus: LimitsLoadingStatus
    var destination: Destination?
    var alert: ErrorAlert?
    var saveButtonEnable: Bool
    
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
        self.saveButtonEnable = true
    }
}

public extension ListHorizontalRectangleLimitsState {
    
    enum ErrorAlert: Equatable, Identifiable {
        
        public var id: Case {
            
            switch self {
            case .updateLimitsError:
                return .updateLimitsError
            }
        }
                
        case updateLimitsError(String)
        
        var text: String {
            
            switch self {
            case let .updateLimitsError(error):
                return error
            }
        }
        
        public enum Case {
            case updateLimitsError
        }
    }
}

public extension ListHorizontalRectangleLimitsState {
    
    enum Destination: Identifiable, Equatable {
        
        public static func == (lhs: ListHorizontalRectangleLimitsState.Destination, rhs: ListHorizontalRectangleLimitsState.Destination) -> Bool {
            return lhs.id == rhs.id
        }
        
        case settingsView(LandingWrapperViewModel, String, String)

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
            case let .settingsView(landingWrapperViewModel, _, _):
                return landingWrapperViewModel
            }
        }
    }
}

extension ListHorizontalRectangleLimitsState {
    
    var limitsInfo: SVCardLimits? {
        
        if case let .limits(limits) = limitsLoadingStatus {
            return limits
        }
        return nil
    }
}

extension ListHorizontalRectangleLimitsState {
    
    func editEnableFor(_ type: String) -> Bool {
        
        if let item = list.list.first(where: { $0.limitType == type}) {
            return item.action.type == "changeLimit"
            }
        return false
    }
}

