//
//  RootViewModel+openUtilityPayment.swift
//  ForaBank
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
                
            case let .personal(payments):
                
                guard let payment = payment(by: category),
                      let picker = payments.content.categoryPicker.sectionBinder
                else {
                    
                    LoggerAgent.shared.log(category: .payments, message: "Payment type by \(category) not found")
                    return
                }
                
                let element = picker.content.state.elements.first {
                    
                    $0.element.type == payment
                }
                
                guard let element else {
                    
                    return LoggerAgent.shared.log(category: .payments, message: "Element for \(category) not found.")
                }
                
                withAnimation {
                    
                    switchTab(.payments)
                    
                    picker.flow.event(.select(.category(element.element)))
                }
            }
            
        default:
            break
        }
    }
    
    private func legacyPayment(by name: String) -> PTSectionPaymentsView.ViewModel.PaymentsType? {
        
        return name == ProductStatementData.Kind.housingAndCommunalService.rawValue ? .service : nil
    }
    
    private func payment(by name: String) -> RemoteServices.ResponseMapper.ServiceCategory.CategoryType? {
        
        return name == ProductStatementData.Kind.housingAndCommunalService.rawValue ? .housingAndCommunalService : nil
    }
}
