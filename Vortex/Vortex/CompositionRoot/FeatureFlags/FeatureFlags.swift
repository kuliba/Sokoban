//
//  FeatureFlags.swift
//  Vortex
//
//  Created by Igor Malyarov on 06.06.2024.
//

struct FeatureFlags: Equatable {
    
    let c2gFlag: C2GFlag
    let getProductListByTypeV6Flag: GetProductListByTypeV6Flag
    let paymentsTransfersFlag: PaymentsTransfersFlag
    let savingsAccountFlag: SavingsAccountFlag
    let collateralLoanLandingFlag: CollateralLoanLandingFlag
    let splashScreenFlag: SplashScreenFlag
    let orderCardFlag: OrderCardFlag
}
