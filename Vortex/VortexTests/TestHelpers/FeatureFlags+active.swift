//
//  FeatureFlags+active.swift
//  VortexTests
//
//  Created by Igor Malyarov on 17.11.2024.
//

@testable import Vortex

extension FeatureFlags {
    
    static let active: Self = activeExcept()
    
    static func activeExcept(
        c2gFlag: C2GFlag = .inactive,
        creditCardMVPFlag: СreditCardMVPFlag = .active,
        getProductListByTypeV6Flag: GetProductListByTypeV6Flag = .active,
        paymentsTransfersFlag: PaymentsTransfersFlag = .active,
        collateralLoanLandingFlag: CollateralLoanLandingFlag = .active,
        splashScreenFlag: SplashScreenFlag = .inactive,
        orderCardFlag: OrderCardFlag = .active
    ) -> Self {
        
        return .init(
            c2gFlag: c2gFlag,
            creditCardMVPFlag: creditCardMVPFlag,
            getProductListByTypeV6Flag: getProductListByTypeV6Flag,
            paymentsTransfersFlag: paymentsTransfersFlag,
            collateralLoanLandingFlag: collateralLoanLandingFlag,
            splashScreenFlag: splashScreenFlag,
            orderCardFlag: orderCardFlag
        )
    }
}
