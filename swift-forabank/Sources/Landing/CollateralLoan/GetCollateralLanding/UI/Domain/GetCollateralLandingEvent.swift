//
//  GetCollateralLandingEvent.swift
//
//
//  Created by Valentin Ozerov on 12.12.2024.
//

public enum GetCollateralLandingEvent: Equatable {
    
    case changeDesiredAmount(UInt)
    case closeBottomSheet
    case createDraftApplication
    case selectCollateral(String)
    case selectMonthPeriod(UInt)
    case showCollateralBottomSheet
    case showPeriodBottomSheet
    case toggleIHaveSalaryInCompany(Bool)
}
