//
//  CollateralLoanLanding+EffectHandler.swift
//  Vortex
//
//  Created by Valentin Ozerov on 24.12.2024.
//

extension CollateralLoanLandingDomain {
    
    final class EffectHandler {
        
        let load: Load
        
        init(
            load: @escaping Load
        ) {
            self.load = load
        }

        public func handleEffect(_ effect: Effect, dispatch: @escaping Dispatch) {
            
            switch effect {
                
            case .load:
                load { dispatch(.loaded($0)) }
            }
        }

        typealias Dispatch = (Event) -> Void
        typealias Completion = (Result) -> Void
        typealias Load = (@escaping Completion) -> Void
    }
}
