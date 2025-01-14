//
//  GetCollateralLandingDomain+Event.swift
//
//
//  Created by Valentin Ozerov on 12.12.2024.
//

extension GetCollateralLandingDomain {
    
    public enum ViewEvent: Equatable {
        
        case domainEvent(Event)
        case uiEvent(UIEvent)
    }

    public enum Event: Equatable {
        
        case load(String)
        case loaded(Result)
    }
        
    public enum UIEvent: Equatable {
        
        case changeDesiredAmount(UInt)
        case createDraftApplication
        case selectCollateral(String)
        case selectMonthPeriod(UInt)
        case toggleIHaveSalaryInCompany(Bool)
    }
}
