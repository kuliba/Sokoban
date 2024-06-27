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
            historyFilterFlag: loadHistoryFilterFlag(),
            changeSVCardLimitsFlag: loadChangeSVCardLimitsFlag(),
            utilitiesPaymentsFlag: loadUtilitiesPaymentsFlag()
        )
    }
}

enum FeatureFlagKey: String {
    
    case historyFilterFlag = "history_filter"
    case changeSVCardLimitsFlag = "changeSVCardLimits"
    case utilitiesPaymentsFlag = "sber_providers"
}

private extension FeatureFlagsLoader {
    
    func loadUtilitiesPaymentsFlag() -> UtilitiesPaymentsFlag {
        
        switch retrieve(.utilitiesPaymentsFlag) {
        case "sber_providers_live": return .init(.active(.live))
        case "sber_providers_stub": return .init(.active(.stub))
        default:                    return .init(.inactive)
        }
    }
    
    func loadHistoryFilterFlag() -> HistoryFilterFlag {
        
        switch retrieve(.historyFilterFlag) {
        case "history_filter_off": return false
        case "history_filter_on":  return true
        default:                   return false
        }
    }
    
    func loadChangeSVCardLimitsFlag() -> ChangeSVCardLimitsFlag {
        
        switch retrieve(.changeSVCardLimitsFlag) {
        case "changeSVCardLimits_on":  return .init(.active)
        case "changeSVCardLimits_off": return .init(.inactive)
        default:           return .init(.inactive)
        }
    }
}
