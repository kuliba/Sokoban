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
            
        case let .v1(switcher):
            switch switcher.state {
            case .none:
                break
                
            case .corporate:
                break
                
            case let .personal(payments):
                
                guard let payment = payment(by: category) else { return }

                let picker = payments.content.categoryPicker.content
                
                let category = picker.state.elements.first {
                    
                    $0.element.type == payment
                }
                
                guard let category else { return }
                
                withAnimation {
                    
                    switchTab(.payments)
                    
                    payments.content.categoryPicker.flow.event(.select(.category(category.element)))
                }
            }
        }
    }
    
    private func legacyPayment(by name: String) -> PTSectionPaymentsView.ViewModel.PaymentsType? {
        
        switch name {
            
        case "HOUSING_AND_COMMUNAL_SERVICE":
            return .service
            
        default:
            return nil
        }
    }
    
    private func payment(by name: String) -> RemoteServices.ResponseMapper.ServiceCategory.CategoryType? {
        
        switch name {
            
        case "HOUSING_AND_COMMUNAL_SERVICE":
            return .housingAndCommunalService
            
        default:
            return nil
        }
    }

}
