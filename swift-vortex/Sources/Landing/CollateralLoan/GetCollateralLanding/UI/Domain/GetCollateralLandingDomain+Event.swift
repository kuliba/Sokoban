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
        
        case changeDesiredAmount(UInt)
        case load(String)
        case loaded(Result)
        case selectCaseList(String, String)
        case selectCollateral(String)
        case selectMonthPeriod(UInt)
        case toggleIHaveSalaryInCompany(Bool)
    }
        
    public enum ExternalEvent: Equatable {
        
        case createDraftApplication
        case showCaseList(CaseType)
        
        public enum CaseType: Equatable {
            
            case periods([Period])
            case collaterals([Collateral])
        }
    }
    
    public typealias Period = GetCollateralLandingProduct.Calc.Rate
    public typealias Collateral = GetCollateralLandingProduct.Calc.Collateral
}
