//
//  GetCollateralLandingDomain+Reducer.swift
//
//
//  Created by Valentin Ozerov on 13.01.2025.
//

extension GetCollateralLandingDomain {
    
    public final class Reducer {
        
        public init() {}
        
        public func reduce(_ state: State, _ event: Event) -> (State, Effect?) {
           
            var state = state
            var effect: Effect?
            
            switch event {
            case let .load(landingId):
                guard !state.isLoading else { break }
                        
                state.isLoading = true
                effect = .load(landingId)
                
            case let .loaded(result):
                state.isLoading = false
                state.result = result
            // TODO: realize calculator logic
            case .selectCaseList(_):
                break
            case .changeDesiredAmount(_):
                break
            case .createDraftApplication:
                break
            case .selectCollateral(_):
                break
            case .selectMonthPeriod(_):
                break
            case .toggleIHaveSalaryInCompany(_):
                break
            }
            
            return (state, effect)
        }
    }
}
