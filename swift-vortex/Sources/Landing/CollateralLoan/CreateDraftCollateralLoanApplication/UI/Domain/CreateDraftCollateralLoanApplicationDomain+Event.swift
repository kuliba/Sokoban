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
        case period(SelectPeriodEvent)
        case city(SelectCityEvent)
        case tappedContinue
        case tappedSubmit
        case tappedBack
        case applicationCreated(CreateDraftApplicationResult)
        case showSaveConsentsResult(SaveConsentsResult)
    }
    
    public typealias SelectPeriodEvent = OptionalSelectorEvent<PeriodItem>
    public typealias SelectCityEvent = OptionalSelectorEvent<CityItem>
}
