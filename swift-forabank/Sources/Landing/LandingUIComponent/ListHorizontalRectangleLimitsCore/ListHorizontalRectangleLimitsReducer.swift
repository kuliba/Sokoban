//
//  ListHorizontalRectangleLimitsReducer.swift
//
//
//  Created by Andryusina Nataly on 24.06.2024.
//

import Foundation
import UIPrimitives
import SwiftUI
import Combine

public final class ListHorizontalRectangleLimitsReducer {
    
    public init() {}
}

public extension ListHorizontalRectangleLimitsReducer {
    
    func reduce(
        _ state: State,
        _ event: Event
    ) -> (State, Effect?) {
        
        var state = state
        var effect: Effect?
        
        switch event {
            
        case let .updateLimits(result):
            switch result {
            case .failure:
                state.limitsLoadingStatus = .failure
            case let .success(limits):
                state.limitsLoadingStatus = .limits(limits)
            }
            
        case let .buttonTapped(info):
            switch info.action {
            case "changeLimit":
               // state.limitsLoadingStatus = .inflight(.loadingSettingsLimits)
                effect = .loadSVCardLanding
                
            default:
                break
            }
            
        case let .loadedLimits(landingViewModel):
            
            if let landingViewModel {
                state.destination = .settingsView(landingViewModel)
            }
            
        case .dismissDestination:
            state.destination = nil
        }
        
        return (state, effect)
    }
}

public extension ListHorizontalRectangleLimitsReducer {
    
    typealias State = ListHorizontalRectangleLimitsState
    typealias Event = ListHorizontalRectangleLimitsEvent
    typealias Effect = ListHorizontalRectangleLimitsEffect
}
