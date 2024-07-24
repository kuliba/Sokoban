//
//  ListHorizontalRectangleLimitsReducer.swift
//
//
//  Created by Andryusina Nataly on 24.06.2024.
//

import Foundation
import UIPrimitives

public final class ListHorizontalRectangleLimitsReducer {
    
    let makeInformer: (String) -> Void
    private let alertLifespan: DispatchTimeInterval

    public init(
        makeInformer: @escaping (String) -> Void,
        alertLifespan: DispatchTimeInterval = .milliseconds(400)

    ) {
        self.makeInformer = makeInformer
        self.alertLifespan = alertLifespan
    }
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
            
        case let .loadedLimits(landingViewModel, subTitle):
            
            if let landingViewModel {
                state.destination = .settingsView(landingViewModel, subTitle)
            }
        
        case let .saveLimits(limits):
            effect = .saveLimits(limits)
            
        case .dismissDestination:
            state.destination = nil
            
        case let .showAlert(message):
            state.alert = .updateLimitsError(message)
            
        case let .delayAlert(message):
            effect = .showAlert(message, alertLifespan)
            
        case let .informer(message):
            makeInformer(message)
        }
        
        return (state, effect)
    }
}

public extension ListHorizontalRectangleLimitsReducer {
    
    typealias State = ListHorizontalRectangleLimitsState
    typealias Event = ListHorizontalRectangleLimitsEvent
    typealias Effect = ListHorizontalRectangleLimitsEffect
}
