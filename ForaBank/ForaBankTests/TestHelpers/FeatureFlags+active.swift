//
//  FeatureFlags+active.swift
//  ForaBankTests
//
//  Created by Igor Malyarov on 17.11.2024.
//

@testable import ForaBank

extension FeatureFlags {
    
    static let active: Self = .init(
        changeSVCardLimitsFlag: .active,
        getProductListByTypeV6Flag: .active,
        marketplaceFlag: .active,
        historyFilterFlag: true,
        paymentsTransfersFlag: .active,
        utilitiesPaymentsFlag: .stub,
        savingsAccountFlag: .active,
        collateralLoanLandingFlag: .active
    )
}
