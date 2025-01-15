//
//  GetCollateralLandingDomain+Event.swift
//
//
//  Created by Valentin Ozerov on 12.12.2024.
//

extension GetCollateralLandingDomain {
    
    public enum ViewEvent: Equatable {
        
        case domainEvent(Event)
        case externalEvent(ExternalEvent)
    }

    public enum Event: Equatable {
        
        case load(String)
        case loaded(Result)
        case selectCaseList(String)
        case changeDesiredAmount(UInt)
        case createDraftApplication
        case selectCollateral(String)
        case selectMonthPeriod(UInt)
        case toggleIHaveSalaryInCompany(Bool)
    }
        
    public enum ExternalEvent: Equatable {
        
        case showCaseList(CaseType)
        
        public enum CaseType: Equatable {
            
            case period
            case deposit
        }
    }
}
