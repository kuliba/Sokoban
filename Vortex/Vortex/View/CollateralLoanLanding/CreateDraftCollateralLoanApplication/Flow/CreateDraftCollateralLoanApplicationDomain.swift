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
    typealias ContentError = CollateralLoanLandingCreateDraftCollateralLoanApplicationUI.BackendFailure<InformerData>

    // MARK: - Flow
    
    typealias FlowDomain = Vortex.FlowDomain<Select, Navigation>
    typealias Flow = FlowDomain.Flow
    typealias Notify = FlowDomain.Notify
    
    typealias Confirmation = TimedOTPInputViewModel
    
    enum Select: Equatable {
        
        case showSaveConsentsResult(SaveConsentsResult<InformerData>)
    }
    
    enum Navigation {

        case failure(CollateralLoanLandingCreateDraftCollateralLoanApplicationUI.BackendFailure<InformerData>)
        case saveConsents(CollateralLandingApplicationSaveConsentsResult)
        
//        enum FlowFailure {
//            
//            case timeout(InformerData)
//            case error(String)
//        }
    }
}
