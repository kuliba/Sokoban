//
//  GetCollateralLandingDomain.swift
//  Vortex
//
//  Created by Valentin Ozerov on 13.01.2025.
//

import RxViewModel
import CollateralLoanLandingGetCollateralLandingUI

extension GetCollateralLandingDomain {

    // MARK: - Binder
    
    typealias Binder = Vortex.Binder<Content, Flow>
    typealias BinderComposer = Vortex.BinderComposer<Content, Select, Navigation>
    
    // MARK: - Content
    
    typealias Content = RxViewModel<State, Event, Effect>
    typealias Domain = GetCollateralLandingDomain
    typealias State = Domain.State
    typealias Event = Domain.Event
    typealias Effect = Domain.Effect
    
    // MARK: - Flow
    
    typealias FlowDomain = Vortex.FlowDomain<Select, Navigation>
    typealias Flow = FlowDomain.Flow
    
    typealias NotifyEvent = FlowDomain.NotifyEvent
    typealias Notify = (NotifyEvent) -> Void
    
    enum Select: Equatable {
        // TODO: Replace to payload
        case createDraftCollateralLoanApplication(String)
    }
    
    enum Navigation {

        // TODO: Need to realize binder in the future
        case createDraftCollateralLoanApplication(String)
    }
}
