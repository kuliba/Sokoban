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
                
                // set default value
                if state.selectedCollateralType == "" {
                    
                    state.selectedCollateralType = state.product?.calc.collaterals.first?.type ?? ""
                }
                
            case .selectCaseList(_,_):
                // TODO: need to realize
                break

            case let .changeDesiredAmount(newValue):
                state.desiredAmount = newValue
                
            case let .selectCollateral(collateral):
                state.selectedCollateralType = collateral

            case let .selectMonthPeriod(period):
                state.selectedMonthPeriod = period

            case let .togglePayrollClient(payrollClient):
                state.payrollClient = payrollClient
            }
            
            return (state, effect)
        }
    }
}
