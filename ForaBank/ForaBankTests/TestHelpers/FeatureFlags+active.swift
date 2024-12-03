//
//  FeatureFlags+active.swift
//  ForaBankTests
//
//  Created by Igor Malyarov on 17.11.2024.
//

@testable import ForaBank

extension FeatureFlags {
    
    static let active: Self = activeExcept()
    
    static func activeExcept(
        getProductListByTypeV6Flag: GetProductListByTypeV6Flag = .active,
        historyFilterFlag: HistoryFilterFlag = true,
        paymentsTransfersFlag: PaymentsTransfersFlag = .active,
        savingsAccountFlag: SavingsAccountFlag = .active,
        collateralLoanLandingFlag: CollateralLoanLandingFlag = .active
    ) -> Self {
        
        return .init(
            getProductListByTypeV6Flag: getProductListByTypeV6Flag,
            historyFilterFlag: historyFilterFlag,
            paymentsTransfersFlag: paymentsTransfersFlag,
            savingsAccountFlag: savingsAccountFlag,
            collateralLoanLandingFlag: collateralLoanLandingFlag
        )
    }
}
