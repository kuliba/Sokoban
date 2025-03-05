//
//  GetCollateralLandingDomain.swift
//  Vortex
//
//  Created by Valentin Ozerov on 13.01.2025.
//

import RxViewModel
import CollateralLoanLandingGetCollateralLandingUI
import CollateralLoanLandingCreateDraftCollateralLoanApplicationUI

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
        case createDraft(Payload)
        case showCaseList(State.BottomSheet.SheetType)
    }
    
    enum Navigation {

        case createDraft(DraftDomain.Binder)
        case showBottomSheet(GetCollateralLandingDomain.State.BottomSheet.SheetType)
    }
    
    typealias DraftDomain = CreateDraftCollateralLoanApplicationDomain
}
