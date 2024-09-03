//
//  FeatureFlagsLoader.swift
//  ForaBank
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
            changeSVCardLimitsFlag: loadChangeSVCardLimitsFlag(),
            getProductListByTypeV6Flag: loadGetProductListByTypeV6Flag(),
            marketplaceFlag: loadMarketplaceFlag(),
            historyFilterFlag: loadHistoryFilterFlag(),
            paymentsTransfersFlag: loadPaymentsTransfersFlag(),
            utilitiesPaymentsFlag: loadUtilitiesPaymentsFlag()
        )
    }
}

enum FeatureFlagKey: String {
    
    case changeSVCardLimitsFlag = "changeSVCardLimits"
    case getProductListByTypeV6Flag = "getProductListByTypeV6"
    case marketplaceFlag = "marketplace"
    case historyFilterFlag = "history_filter"
    case paymentsTransfersFlag = "payments_transfers"
    case utilitiesPaymentsFlag = "sber_providers"
}

private extension FeatureFlagsLoader {
    
    func loadChangeSVCardLimitsFlag() -> ChangeSVCardLimitsFlag {
        
        switch retrieve(.changeSVCardLimitsFlag) {
        case "1":  return .init(.active)
        default:   return .init(.inactive)
        }
    }
    
    func loadGetProductListByTypeV6Flag() -> GetProductListByTypeV6Flag {
        
        switch retrieve(.getProductListByTypeV6Flag) {
        case "1":  return .init(.active)
        default:   return .init(.inactive)
        }
    }

    func loadMarketplaceFlag() -> MarketplaceFlag {
        
        switch retrieve(.marketplaceFlag) {
        case "1":  return .init(.active)
        default:   return .init(.inactive)
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
        case "1":  return .init(.active)
        default:   return .init(.inactive)
        }
    }
    
    func loadUtilitiesPaymentsFlag() -> UtilitiesPaymentsFlag {
        
        switch retrieve(.utilitiesPaymentsFlag) {
        case "sber_providers_live": return .init(.active(.live))
        case "sber_providers_stub": return .init(.active(.stub))
        default:                    return .init(.inactive)
        }
    }
}
