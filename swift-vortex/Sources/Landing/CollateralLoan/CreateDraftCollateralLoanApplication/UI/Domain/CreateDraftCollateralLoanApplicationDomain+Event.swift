//
//  CreateDraftCollateralLoanApplicationDomain+Event.swift
//  
//
//  Created by Valentin Ozerov on 16.01.2025.
//

import Foundation

extension CreateDraftCollateralLoanApplicationDomain {
    
    public enum Event: Equatable {
        
        case selectedAmount(UInt)
        case selectedPeriod(String)
        case selectedCity(String)
        case tappedContinue
        case tappedSubmit
        case applicationCreated(CreateDraftApplicationResult)
        case showSaveConsentsResult(SaveConsentsResult)
    }
}
