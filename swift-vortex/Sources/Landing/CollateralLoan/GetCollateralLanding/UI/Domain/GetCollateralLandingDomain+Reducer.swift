//
//  GetCollateralLandingDomain+Reducer.swift
//
//
//  Created by Valentin Ozerov on 13.01.2025.
//

extension GetCollateralLandingDomain {
    
    public final class Reducer<InformerPayload> where InformerPayload: Equatable {
        
        public init() {}
        
        public func reduce(_ state: State<InformerPayload>, _ event: Event<InformerPayload>)
            -> (State<InformerPayload>, Effect?) {
           
            var state = state
            var effect: Effect?
            
            switch event {
            case let .load(landingID):
                
                if !state.status.isLoading {
                    let oldProduct = state.status.oldProduct
                    state.status = .inflight(oldProduct)
                    effect = .load(landingID)
                }
                
            case let .loaded(product):
                state.status = .loaded(product)
                state.selectedCollateralType = product.calc.collaterals.first?.type ?? ""
                state.desiredAmount = product.calc.amount.minIntValue

            case let .failure(failure):
                switch failure {
                case let .alert(message):
                    let oldProduct = state.status.oldProduct
                    state.status = .failure(.alert(message), oldProduct)
                    
                case let .informer(informer):
                    let oldProduct = state.status.oldProduct
                    state.status = .failure(.informer(informer), oldProduct)
                }
                
            case .dismissFailure:
                if let product = state.status.oldProduct {
                    state.status = .loaded(product)
                }
                state.backendFailure = nil

            case let .changeDesiredAmount(newValue):
                state.desiredAmount = newValue
                
            case let .selectCollateral(collateral):
                state.selectedCollateralType = collateral

            case let .selectMonthPeriod(period):
                state.selectedMonthPeriod = period

            case let .togglePayrollClient(payrollClient):
                state.payrollClient = payrollClient
                
            case let .enterDesiredAmount(newValue):
                if
                    let newDesiredAmount = UInt(newValue.filter(\.isWholeNumber)),
                    newDesiredAmount != state.desiredAmount {
                    
                    state.desiredAmount = newDesiredAmount
                }
                
            case let .setAmountResponder(value):
                state.isAmountTextFieldFirstResponder = value
            }
            
            return (state, effect)
        }
    }
}
