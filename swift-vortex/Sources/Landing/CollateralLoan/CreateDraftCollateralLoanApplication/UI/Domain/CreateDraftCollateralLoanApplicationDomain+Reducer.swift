//
//  CreateDraftCollateralLoanApplicationDomain+Reducer.swift
//  
//
//  Created by Valentin Ozerov on 16.01.2025.
//

extension CreateDraftCollateralLoanApplicationDomain {
    
    public final class Reducer {
        
        public init() {}
        
        public func reduce(_ state: State, _ event: Event) -> (State, Effect?) {
           
            var state = state
            var effect: Effect?
            
            switch event {
            case .selectedAmount(_):
                break
                
            case .selectedPeriod(_):
                break
                
            case .selectedCity(_):
                break
                
            case .tappedContinue:
                state.isLoading = true
                effect = .createDraftApplication(state.createDraftApplicationPayload)

            case let .applicationCreated(result):
                state.applicationId = try? result.get().applicationId
                state.stage = .confirm
                state.isLoading = false

            case .tappedSubmit:
                state.isLoading = true
                effect = .saveConsents(state.saveConsentspayload)     
                
            case let .showSaveConsentsResult(result):
                state.isLoading = false
                state.saveConsentsResult = result
                
            case .inputComponentEvent(_):
                break
            }
            
            return (state, effect)
        }
    }
}
