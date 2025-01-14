//
//  GetCollateralLandingDomain+Event.swift
//
//
//  Created by Valentin Ozerov on 12.12.2024.
//

extension GetCollateralLandingDomain {
    
    public enum Event: Equatable {
        
        case changeDesiredAmount(UInt)
        case createDraftApplication
        case selectCollateral(String)
        case selectMonthPeriod(UInt)
        case toggleIHaveSalaryInCompany(Bool)
    }
}
