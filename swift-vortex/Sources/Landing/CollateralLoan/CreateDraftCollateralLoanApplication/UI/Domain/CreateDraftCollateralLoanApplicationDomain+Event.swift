//
//  CreateDraftCollateralLoanApplicationDomain+Event.swift
//
//
//  Created by Valentin Ozerov on 16.01.2025.
//

import Foundation
import InputComponent
import TextFieldDomain
import OptionalSelectorComponent

extension CreateDraftCollateralLoanApplicationDomain {
    
    public enum Event<Confirmation, InformerPayload> {
        
        // MARK: UI events
        case amount(TextInputEvent)
        case checkConsent(String)
        case city(SelectCityEvent)
        case period(SelectPeriodEvent)
        case back
        case `continue`
        case submit
        case dismissFailure
        
        case applicationCreated(CreateDraftApplicationCreatedResult<Confirmation, InformerPayload>)
        case confirmed(Confirmation)
        case failure(BackendFailure<InformerPayload>)
        // case failure(Failure)
        case gettedVerificationCode(GetVerificationCodeResult<InformerPayload>)
        case showSaveConsentsResult(SaveConsentsResult<InformerPayload>)
        case otpEvent(OTPEvent)
        
        public enum Failure {
            case alert(String)
            case informer(InformerPayload)
        }
        
        public enum OTPEvent {
        
            case otp(String)
            case getVerificationCode
        }
    }
}

public extension CreateDraftCollateralLoanApplicationDomain {

    typealias GetVerificationCodeResult<InformerPayload> = Result<Int, BackendFailure<InformerPayload>>
    typealias SelectPeriodEvent = OptionalSelectorEvent<PeriodItem>
    typealias SelectCityEvent = OptionalSelectorEvent<CityItem>
}
