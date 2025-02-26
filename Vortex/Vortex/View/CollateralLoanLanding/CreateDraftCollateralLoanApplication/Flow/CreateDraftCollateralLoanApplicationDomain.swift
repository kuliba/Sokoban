//
//  CreateDraftCollateralLoanApplicationDomain.swift
//  Vortex
//
//  Created by Valentin Ozerov on 16.01.2025.
//

import CollateralLoanLandingCreateDraftCollateralLoanApplicationUI
import OTPInputComponent
import RxViewModel

extension CreateDraftCollateralLoanApplicationDomain {

    // MARK: - Binder
    
    typealias Binder = Vortex.Binder<Content, Flow>
    
    // MARK: - Content
    
    typealias Content = RxViewModel<State<Confirmation, InformerData>, Event<Confirmation, InformerData>, Effect>
    typealias ContentError = CollateralLoanLandingCreateDraftCollateralLoanApplicationUI.BackendFailure<InformerPayload>
    typealias ContentReducer = Reducer<Confirmation, InformerData>
    typealias ContentEffectHandler = EffectHandler<Confirmation, InformerPayload>
    typealias ContentEvent = Event<Confirmation, InformerPayload>
    typealias ContentState = State<Confirmation, InformerPayload>
    typealias OTPEvent = ContentEvent.OTPEvent
    
    // MARK: - Flow
    
    typealias FlowDomain = Vortex.FlowDomain<Select, Navigation>
    typealias Flow = FlowDomain.Flow
    typealias Notify = FlowDomain.Notify
    
    typealias RequestResult = CreateDraftApplicationCreatedResult<Confirmation, InformerPayload>
    
    typealias Confirmation = TimedOTPInputViewModel
    typealias InformerPayload = InformerData
    
    enum Select: Equatable {
        
        case showSaveConsentsResult(SaveConsentsResult<InformerData>)
    }
    
    enum Navigation {

        case failure(ContentError)
        case saveConsents(CollateralLandingApplicationSaveConsentsResult)
    }
}
