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
            case "changeLimit", "viewLimit":
               // state.limitsLoadingStatus = .inflight(.loadingSettingsLimits)
                effect = .loadSVCardLanding(info.limitType)
                
            default:
                break
            }
            
        case let .loadedLimits(landingViewModel, subTitle, limitType):
            
            if let landingViewModel {
                
                landingViewModel.updateCardLimitsInfo(.init(type: limitType, svCardLimits: state.limitsInfo, editEnable: state.editEnableFor(limitType)))
                
                state.destination = .settingsView(landingViewModel, subTitle, limitType)
            }
        
        case let .saveLimits(limits):
            effect = .saveLimits(limits)
            
        case .dismissDestination:
            state.destination = nil
            
        case let .showAlert(message):
            state.alert = .updateLimitsError(message)
            
        case let .delayAlert(message):
            effect = .showAlert(message, alertLifespan)
            
        case let .informerWithLimits(message, limits):
            makeInformer(message)
            // TODO: update limits
            
        case let .limitChanging(newLimits):

            state.saveButtonEnable = limitsIsChanged(state.limitsInfo, newLimits)
        }
        
        return (state, effect)
    }
    
    private func limitsIsChanged(
        _ oldLimits: SVCardLimits?,
        _ newLimits: [BlockHorizontalRectangularEvent.Limit]
    ) -> Bool {
        
        guard !newLimits.isEmpty else { return false }
        
        var limitIsChanged = false
        
        for newLimit in newLimits {
            if oldLimits?.limitValue(by: newLimit.id) != newLimit.value {
                limitIsChanged = true
                break
            }
        }
        return limitIsChanged
    }
}

private extension SVCardLimits {
    
    typealias LimitType = String
    
    func limitValue(by type: LimitType) -> Decimal {
        
        let limitValue = self.limitsList.first(where: { $0.limits.first(where: { $0.name == type }) != nil })
        
        return limitValue?.limits.first(where: { $0.name == type })?.value ?? 0
    }
}

public extension ListHorizontalRectangleLimitsReducer {
    
    typealias State = ListHorizontalRectangleLimitsState
    typealias Event = ListHorizontalRectangleLimitsEvent
    typealias Effect = ListHorizontalRectangleLimitsEffect
}
