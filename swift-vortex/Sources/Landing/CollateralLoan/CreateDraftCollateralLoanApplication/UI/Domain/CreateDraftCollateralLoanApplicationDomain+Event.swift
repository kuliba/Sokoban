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
    
    public enum Event<Confirmation> {
        
        case amount(TextInputEvent)
        case applicationCreated(CreateDraftApplicationResult)
        case checkConsent(String)
        case city(SelectCityEvent)
        case otp(String)
        case confirmed(Confirmation)
        case period(SelectPeriodEvent)
        case getVerificationCode
        case gettedVerificationCode(GetVerificationCodeResult)
        case otpValidated
        case showSaveConsentsResult(SaveConsentsResult)
        case tappedBack
        case tappedContinue
        case tappedSubmit        
    }
    
    public typealias GetVerificationCodeResult = Result<Int, LoadResultFailure>
    public typealias SelectPeriodEvent = OptionalSelectorEvent<PeriodItem>
    public typealias SelectCityEvent = OptionalSelectorEvent<CityItem>
}
