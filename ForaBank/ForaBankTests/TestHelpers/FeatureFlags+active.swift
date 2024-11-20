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
        changeSVCardLimitsFlag: ChangeSVCardLimitsFlag = .active,
        getProductListByTypeV6Flag: GetProductListByTypeV6Flag = .active,
        marketplaceFlag: MarketplaceFlag = .active,
        historyFilterFlag: HistoryFilterFlag = true,
        paymentsTransfersFlag: PaymentsTransfersFlag = .active,
        savingsAccountFlag: SavingsAccountFlag = .active,
        collateralLoanLandingFlag: CollateralLoanLandingFlag = .active
    ) -> Self {
        
        return .init(
            changeSVCardLimitsFlag: changeSVCardLimitsFlag,
            getProductListByTypeV6Flag: getProductListByTypeV6Flag,
            marketplaceFlag: marketplaceFlag,
            historyFilterFlag: historyFilterFlag,
            paymentsTransfersFlag: paymentsTransfersFlag,
            savingsAccountFlag: savingsAccountFlag,
            collateralLoanLandingFlag: collateralLoanLandingFlag
        )
    }
}
