//
//  RootViewModelFactory+makeCreateDraftCollateralLoanApplicationBinder.swift
//  Vortex
//
//  Created by Valentin Ozerov on 16.01.2025.
//

import CollateralLoanLandingCreateDraftCollateralLoanApplicationUI
import RemoteServices
import Foundation
import Combine

extension RootViewModelFactory {
    
    func makeCreateDraftCollateralLoanApplicationBinder(payload: String)
        -> CreateDraftCollateralLoanApplicationDomain.Binder {

        let content = makeContent()

        return composeBinder(
            content: content,
            delayProvider: delayProvider,
            getNavigation: getNavigation,
            witnesses: .empty
        )
    }
    
    // MARK: - Content
    
    private func makeContent() -> CreateDraftCollateralLoanApplicationDomain.Content {
        
        let reducer = CreateDraftCollateralLoanApplicationDomain.Reducer()
        let effectHandler = CreateDraftCollateralLoanApplicationDomain.EffectHandler()
        
        return .init(
            initialState: .init(),
            reduce: reducer.reduce(_:_:),
            handleEffect: effectHandler.handleEffect(_:dispatch:),
            scheduler: schedulers.main
        )
    }
    
    // MARK: - Flow
    
    private func getNavigation(
        select: CreateDraftCollateralLoanApplicationDomain.Select,
        notify: @escaping CreateDraftCollateralLoanApplicationDomain.Notify,
        completion: @escaping (CreateDraftCollateralLoanApplicationDomain.Navigation) -> Void
    ) {
        switch select {
        case let .submitAnApplication(id):
            completion(.submitAnApplication(id))
        }
    }

    private func delayProvider(
        navigation: CreateDraftCollateralLoanApplicationDomain.Navigation
    ) -> Delay {
  
        switch navigation {
            
        case .submitAnApplication(_):
            return .milliseconds(100)
        }
    }
}
