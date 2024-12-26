//
//  RootViewModel+openUtilityPayment.swift
//  Vortex
//
//  Created by Andryusina Nataly on 25.10.2024.
//

import Foundation
import RemoteServices
import SwiftUI

extension RootViewModel {
    
    func openUtilityPayment(
        category: String,
        switchTab: (RootViewModel.TabType) -> Void
    ) {
        switch tabsViewModel.paymentsModel {
            
        case let .legacy(legacy):
            
            guard let payment = legacyPayment(by: category) else { return }
            
            withAnimation {
                switchTab(.payments)
                
                if let section = legacy.sections.compactMap({ $0 as? PTSectionPaymentsView.ViewModel }).first {
                    
                    section.action.send( PTSectionPaymentsViewAction.ButtonTapped.Payment(type: payment))
                }
            }
            
        case let .v1(switcher as PaymentsTransfersSwitcher):
            switch switcher.state {
            case .none:
                break
                
            case .corporate:
                break
                
            case .personal:
                guard category == "HOUSING_AND_COMMUNAL_SERVICE" else {
                    
                    return LoggerAgent.shared.log(category: .payments, message: "Payment type by \(category) not found")
                }
                
                action.send(RootEvent.standardPayment("housingAndCommunalService"))
            }
            
        default:
            break
        }
    }
    
    private func legacyPayment(by name: String) -> PTSectionPaymentsView.ViewModel.PaymentsType? {
        
        return name == ProductStatementData.Kind.housingAndCommunalService.rawValue ? .service : nil
    }
}
