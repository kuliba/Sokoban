//
//  GetCollateralLandingEvent.swift
//
//
//  Created by Valentin Ozerov on 12.12.2024.
//

public enum GetCollateralLandingEvent: Equatable {
    
    case toggleIHaveSalaryInCompany(Bool)
    case selectMonthPeriod(UInt)
    case selectCollateral(String)
    case changeDesiredAmount(Int)
    case createDraftApplication
    case closeBottomSheet
}
