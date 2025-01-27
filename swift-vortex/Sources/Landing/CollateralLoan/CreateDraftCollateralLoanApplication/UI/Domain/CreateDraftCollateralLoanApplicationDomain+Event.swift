//
//  CreateDraftCollateralLoanApplicationDomain+Event.swift
//  
//
//  Created by Valentin Ozerov on 16.01.2025.
//

import Foundation
import InputComponent
import TextFieldDomain

extension CreateDraftCollateralLoanApplicationDomain {
    
    public enum Event: Equatable {
        
        case selectedAmount(UInt)
        case selectedPeriod(String)
        case selectedCity(String)
        case tappedContinue
        case tappedSubmit
        case applicationCreated(CreateDraftApplicationResult)
        case showSaveConsentsResult(SaveConsentsResult)
        case inputComponentEvent(InputComponentEvent)
        
        public enum InputComponentEvent: Equatable {

            case textField(TextFieldAction)
        }
    }
}

extension TextInputEvent {
    
    public var inputComponentEvent: CreateDraftCollateralLoanApplicationDomain.Event.InputComponentEvent {
        
        switch self {
        case let .textField(event):
            return .textField(event)
        }
    }
}
