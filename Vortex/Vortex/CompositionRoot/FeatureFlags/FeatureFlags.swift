//
//  FeatureFlags.swift
//  ForaBank
//
//  Created by Igor Malyarov on 06.06.2024.
//

struct FeatureFlags: Equatable {
    
    let getProductListByTypeV6Flag: GetProductListByTypeV6Flag
    let historyFilterFlag: HistoryFilterFlag
    let paymentsTransfersFlag: PaymentsTransfersFlag
    let savingsAccountFlag: SavingsAccountFlag
    let collateralLoanLandingFlag: CollateralLoanLandingFlag
}
