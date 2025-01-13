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
            getProductListByTypeV6Flag: loadGetProductListByTypeV6Flag(),
            historyFilterFlag: loadHistoryFilterFlag(),
            paymentsTransfersFlag: loadPaymentsTransfersFlag(),
            savingsAccountFlag: loadSavingsAccountFlag(),
            collateralLoanLandingFlag: loadCollateralLoanLandingFlag(),
            splashScreenFlag: loadSplashScreenFlag(),
            orderCardFlag: loadOrderCardFlag()
        )
    }
}

enum FeatureFlagKey: String {
    
    case getProductListByTypeV6Flag = "getProductListByTypeV6"
    case historyFilterFlag = "history_filter"
    case paymentsTransfersFlag = "payments_transfers"
    case collateralLoanLandingFlag = "collateralLoanLanding"
    case savingsAccountFlag = "savingsAccount"
    case splashScreenFlag = "splashScreen"
    case orderCardFlag = "orderCard"
}

private extension FeatureFlagsLoader {
    
    func loadGetProductListByTypeV6Flag() -> GetProductListByTypeV6Flag {
        
        switch retrieve(.getProductListByTypeV6Flag) {
        case "1":  return .active
        default:   return .inactive
        }
    }

    func loadSavingsAccountFlag() -> SavingsAccountFlag {
        
        switch retrieve(.savingsAccountFlag) {
        case "1":  return .active
        default:   return .inactive
        }
    }

    func loadHistoryFilterFlag() -> HistoryFilterFlag {
        
        switch retrieve(.historyFilterFlag) {
        case "1":  return true
        default:   return false
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
