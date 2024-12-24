//
//  CollateralLoanLandingViewModelFactory.swift
//  Vortex
//
//  Created by Valentin Ozerov on 24.12.2024.
//

struct CollateralLoanLandingFactory {
    
    func makeViewModel() -> ViewModel {
        
        let reducer = Reducer()
        let effectHandler = EffectHandler(load: { _ in print("#####") })
        
        return .init(
            initialState: .init(isLoading: true),
            reduce: reducer.reduce(_:_:),
            handleEffect: effectHandler.handleEffect(_:dispatch:)
        )
    }

    typealias Domain = CollateralLoanLandingDomain
    typealias Reducer = Domain.Reducer
    typealias ViewModel = Domain.ViewModel
    typealias EffectHandler = Domain.EffectHandler
}
