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
        
        case showSaveConsentsResult(SaveConsentsResult)
    }
    
    enum Navigation: Equatable {

        case showSaveConsentsResult(SaveConsentsResult)
    }
}
