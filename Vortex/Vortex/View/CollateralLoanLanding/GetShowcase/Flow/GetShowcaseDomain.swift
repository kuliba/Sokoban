//
//  CollateralLoanLandingDomain.swift
//  Vortex
//
//  Created by Valentin Ozerov on 10.01.2025.
//

import RxViewModel
import CollateralLoanLandingGetShowcaseUI
import CollateralLoanLandingGetCollateralLandingUI

extension GetShowcaseDomain {

    // MARK: - Binder
    
    typealias Binder = Vortex.Binder<Content, Flow>
    typealias BinderComposer = Vortex.BinderComposer<Content, Select, Navigation>
    
    // MARK: - Content
    
    typealias Content = RxViewModel<
        GetShowcaseDomain.State<InformerPayload>,
        GetShowcaseDomain.Event<InformerPayload>,
        GetShowcaseDomain.Effect
    >
    typealias ContentError = CollateralLoanLandingGetShowcaseUI.BackendFailure<InformerPayload>

    // MARK: - Flow
    
    typealias FlowDomain = Vortex.FlowDomain<Select, Navigation>
    typealias Flow = FlowDomain.Flow
    
    typealias NotifyEvent = FlowDomain.NotifyEvent
    typealias Notify = (NotifyEvent) -> Void
    typealias InformerPayload = InformerData

    enum Select: Equatable {

        case landing(String)
        case failure(Failure)
    }
    
    enum Navigation {

        case landing(String, GetCollateralLandingDomain.Binder)
        case failure(Failure)
    }
    
    enum Failure: Equatable {
        
        case alert(String)
        case informer(InformerData)
    }
}
