//
//  FeatureFlagsLoader.swift
//  Vortex
//
//  Created by Igor Malyarov on 06.06.2024.
//

import Foundation
import Tagged

final class FeatureFlagsLoader {
    
    private let retrieve: Retrieve
    
    init(retrieve: @escaping Retrieve) {
        
        self.retrieve = retrieve
    }
    
    typealias Retrieve = (FeatureFlagKey) -> String?
}

extension FeatureFlagsLoader {
    
    func load() -> FeatureFlags {
        
        return .init(
            c2gFlag: loadC2GFlag(),
            creditCardMVPFlag: loadСreditCardMVPFlag(),
            getProductListByTypeV6Flag: loadGetProductListByTypeV6Flag(),
            paymentsTransfersFlag: loadPaymentsTransfersFlag(),
            collateralLoanLandingFlag: loadCollateralLoanLandingFlag(),
            splashScreenFlag: loadSplashScreenFlag(),
            orderCardFlag: loadOrderCardFlag()
        )
    }
}

enum FeatureFlagKey: String {
    
    case c2gFlag = "c2g"
    case creditCardMVPFlag = "creditCardMVP"
    case getProductListByTypeV6Flag = "getProductListByTypeV6"
    case paymentsTransfersFlag = "payments_transfers"
    case collateralLoanLandingFlag = "collateralLoanLanding"
    case splashScreenFlag = "splashScreen"
    case orderCardFlag = "orderCard"
}

private extension FeatureFlagsLoader {
    
    func loadC2GFlag() -> C2GFlag {
        
        switch retrieve(.c2gFlag) {
        case "1":  return .active
        default:   return .inactive
        }
    }
    
    func loadСreditCardMVPFlag() -> СreditCardMVPFlag {
        
        switch retrieve(.creditCardMVPFlag) {
        case "1":  return .active
        default:   return .inactive
        }
    }
    
    func loadGetProductListByTypeV6Flag() -> GetProductListByTypeV6Flag {
        
        switch retrieve(.getProductListByTypeV6Flag) {
        case "1":  return .active
        default:   return .inactive
        }
    }
    
    func loadPaymentsTransfersFlag() -> PaymentsTransfersFlag {
        switch retrieve(.paymentsTransfersFlag) {
        case "1":  return .active
        default:   return .inactive
        }
    }
    
    func loadCollateralLoanLandingFlag() -> CollateralLoanLandingFlag {
        
        switch retrieve(.collateralLoanLandingFlag) {
        case "1":  return .active
        default:   return .inactive
        }
    }
    
    func loadSplashScreenFlag() -> SplashScreenFlag {
        
        switch retrieve(.splashScreenFlag) {
        case "1": return .active
        default: return .inactive
        }
    }
    
    func loadOrderCardFlag() -> OrderCardFlag {
        
        switch retrieve(.orderCardFlag) {
        case "1":  return .active
        default:   return .inactive
        }
    }
}
