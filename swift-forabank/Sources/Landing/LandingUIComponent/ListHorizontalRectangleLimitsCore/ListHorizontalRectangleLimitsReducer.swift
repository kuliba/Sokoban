//
//  ListHorizontalRectangleLimitsReducer.swift
//
//
//  Created by Andryusina Nataly on 24.06.2024.
//

import Foundation
import UIPrimitives
import SVCardLimitAPI

public final class ListHorizontalRectangleLimitsReducer {
    
    let makeInformer: (String) -> Void
    private let alertLifespan: DispatchTimeInterval
    private let getCurrencySymbol: GetCurrencySymbol

    public init(
        makeInformer: @escaping (String) -> Void,
        getCurrencySymbol: @escaping GetCurrencySymbol,
        alertLifespan: DispatchTimeInterval = .milliseconds(400)
    ) {
        self.makeInformer = makeInformer
        self.getCurrencySymbol = getCurrencySymbol
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
            state.saveButtonEnable = false
            effect = .saveLimits(limits)
            
        case .dismissDestination:
            state.destination = nil
            state.saveButtonEnable = false

        case let .showAlert(message):
            state.alert = .updateLimitsError(message)
            
        case let .delayAlert(message):
            effect = .showAlert(message, alertLifespan)
            
        case let .informerWithLimits(message, limits):
            makeInformer(message)
            state.limitsLoadingStatus = .limits(.init(limits, getCurrencySymbol: getCurrencySymbol))
            state.saveButtonEnable = false

        case let .limitChanging(newLimits, newValueMoreThenMaxValue):

            state.saveButtonEnable = !newValueMoreThenMaxValue ? limitsIsChanged(state.limitsInfo, newLimits) : false
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
    typealias GetCurrencySymbol = (Int) -> String?
}

extension SVCardLimits {
    
    init(
        _ limits: [GetSVCardLimitsResponse.LimitItem],
        getCurrencySymbol: (Int) -> String?
    ) {
       self.init(limitsList: limits.map {
           SVCardLimits.LimitItem.init(type: $0.type, limits: $0.limits.map { limit in
               .init(
                currency: getCurrencySymbol(limit.currency) ?? "",
                currentValue: limit.currentValue,
                name: limit.name,
                value: limit.value
               )
           })
       })
    }
}
