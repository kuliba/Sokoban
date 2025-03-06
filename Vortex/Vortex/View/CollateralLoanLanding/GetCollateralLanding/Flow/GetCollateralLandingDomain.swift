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
    
    typealias Content = RxViewModel<State<InformerPayload>, Event<InformerPayload>, Effect>
    typealias ContentError = CollateralLoanLandingGetCollateralLandingUI.BackendFailure<InformerPayload>
    typealias Domain = GetCollateralLandingDomain
    
    // MARK: - Flow
    
    typealias FlowDomain = Vortex.FlowDomain<Select, Navigation>
    typealias Flow = FlowDomain.Flow
    
    typealias NotifyEvent = FlowDomain.NotifyEvent
    typealias Notify = (NotifyEvent) -> Void
    typealias InformerPayload = InformerData
    
    enum Select: Equatable {
        
        case createDraft(Payload)
        case showCaseList(State<InformerPayload>.BottomSheet.SheetType)
        case failure(Failure)
    }
    
    enum Navigation {

        case createDraft(DraftDomain.Binder)
        case showBottomSheet(State<InformerPayload>.BottomSheet.SheetType)
        case failure(Failure)
    }

    enum Failure: Equatable {
        
        case alert(String)
        case informer(InformerData)
    }

    typealias DraftDomain = CreateDraftCollateralLoanApplicationDomain
}
