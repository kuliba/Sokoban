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
    
    public enum Event: Equatable {
        
        case amount(TextInputEvent)
        case applicationCreated(CreateDraftApplicationResult)
        case city(SelectCityEvent)
        case otp(String)
        case period(SelectPeriodEvent)
        case getVerificationCode
        case gettedVerificationCode(GetVerificationCodeResult)
        case showSaveConsentsResult(SaveConsentsResult)
        case tappedBack
        case tappedContinue
        case tappedSubmit
    }
    
    public typealias GetVerificationCodeResult = Result<Int, ServiceFailure>
    public typealias SelectPeriodEvent = OptionalSelectorEvent<PeriodItem>
    public typealias SelectCityEvent = OptionalSelectorEvent<CityItem>
}
