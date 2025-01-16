//
//  CreateDraftCollateralLoanApplicationDomain+EffectHandler.swift
//
//
//  Created by Valentin Ozerov on 16.01.2025.
//

extension CreateDraftCollateralLoanApplicationDomain {
    
    public final class EffectHandler {

        public init() {}
        
        public func handleEffect(_ effect: Effect, dispatch: @escaping Dispatch) {}

        public typealias Dispatch = (Event) -> Void
    }
}
