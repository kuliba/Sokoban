//
//  CreateDraftCollateralLoanApplicationDomain.swift
//  Vortex
//
//  Created by Valentin Ozerov on 16.01.2025.
//

import CollateralLoanLandingCreateDraftCollateralLoanApplicationUI
import CollateralLoanLandingGetConsentsBackend
import OTPInputComponent
import RemoteServices
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

        case saveConsents(CollateralLandingApplicationSaveConsentsResult)
        case failure(Failure)
    }
    
    enum Failure: Equatable {
        
        case informer(InformerPayload)
        case alert(String)
        case complete
        case offline
        case none
    }
}

public extension CollateralLandingApplicationSaveConsentsResult {
    
    var payload: RemoteServices.RequestFactory.GetConsentsPayload {
        
        .init(
            cryptoVersion: "1.0", // Constant, can be skipped in request
            applicationId: applicationID,
            verificationCode: verificationCode
        )
    }
}
