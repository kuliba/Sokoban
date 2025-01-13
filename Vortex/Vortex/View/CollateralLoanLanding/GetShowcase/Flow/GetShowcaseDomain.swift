//
//  CollateralLoanLandingDomain.swift
//  Vortex
//
//  Created by Valentin Ozerov on 10.01.2025.
//

import RxViewModel
import CollateralLoanLandingGetShowcaseUI

extension GetShowcaseDomain {

    // MARK: - Binder
    
    typealias Binder = Vortex.Binder<Content, Flow>
    typealias BinderComposer = Vortex.BinderComposer<Content, Select, Navigation>
    
    // MARK: - Content
    
    typealias Content = RxViewModel<GetShowcaseDomain.State, GetShowcaseDomain.Event, GetShowcaseDomain.Effect>
    
    // MARK: - Flow
    
    typealias FlowDomain = Vortex.FlowDomain<Select, Navigation>
    typealias Flow = FlowDomain.Flow
    
    typealias NotifyEvent = FlowDomain.NotifyEvent
    typealias Notify = (NotifyEvent) -> Void
    
    enum Select: Equatable {

        case landing(String)
    }
    
    enum Navigation {

        // TODO: Need to realize binder in the future
        case landing(String)
    }
}
