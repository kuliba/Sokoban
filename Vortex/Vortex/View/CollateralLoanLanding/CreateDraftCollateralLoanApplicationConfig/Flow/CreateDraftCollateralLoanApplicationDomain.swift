//
//  CreateDraftCollateralLoanApplicationDomain.swift
//  Vortex
//
//  Created by Valentin Ozerov on 16.01.2025.
//

import RxViewModel

import CollateralLoanLandingCreateDraftCollateralLoanApplicationUI

extension CreateDraftCollateralLoanApplicationDomain {

    // MARK: - Binder
    
    typealias Binder = Vortex.Binder<Content, Flow>
    typealias BinderComposer = Vortex.BinderComposer<Content, Select, Navigation>
    
    // MARK: - Content
    
    typealias Content = RxViewModel<
        CreateDraftCollateralLoanApplicationDomain.State,
        CreateDraftCollateralLoanApplicationDomain.Event,
        CreateDraftCollateralLoanApplicationDomain.Effect
    >
    
    // MARK: - Flow
    
    typealias FlowDomain = Vortex.FlowDomain<Select, Navigation>
    typealias Flow = FlowDomain.Flow
    
    typealias NotifyEvent = FlowDomain.NotifyEvent
    typealias Notify = (NotifyEvent) -> Void
    
    enum Select: Equatable {
        
        // TODO: Replace to payload
        case submitAnApplication(String)
    }
    
    enum Navigation {

        // TODO: Need to realize binder in the future
        case submitAnApplication(String)
    }
}
