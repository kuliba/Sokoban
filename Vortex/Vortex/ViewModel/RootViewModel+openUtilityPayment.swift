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
                
                action.send(RootEvent.select(.standardPayment("housingAndCommunalService")))
            }
            
        default:
            break
        }
    }
    
    private func legacyPayment(by name: String) -> PTSectionPaymentsView.ViewModel.PaymentsType? {
        
        return name == ProductStatementData.Kind.housingAndCommunalService ? .service : nil
    }
}

extension ProductStatementData.Kind {
    
    static let betweenTheir = "BETWEEN_THEIR"
    static let contactAddressless = "CONTACT_ADDRESSLESS"
    static let direct = "DIRECT"
    static let externalEntity = "EXTERNAL_ENTITY"
    static let externalIndivudual = "EXTERNAL_INDIVIDUAL"
    static let housingAndCommunalService = "HOUSING_AND_COMMUNAL_SERVICE"
    static let insideBank = "INSIDE_BANK"
    static let insideOther = "INSIDE_OTHER"
    static let internet = "INTERNET"
    static let mobile = "MOBILE"
    static let notFinance = "NOT_FINANCE"
    static let otherBank = "OTHER_BANK"
    static let outsideCash = "OUTSIDE_CASH"
    static let outsideOther = "OUTSIDE_OTHER"
    static let sfp = "SFP"
    static let transport = "TRANSPORT"
    static let taxes = "TAX_AND_STATE_SERVICE"
    static let c2b = "C2B_PAYMENT"
    static let insideDeposit = "INSIDE_DEPOSIT"
    static let sberQRPayment = "SBER_QR_PAYMENT"
    static let networkMarketing = "NETWORK_MARKETING_SERVICE"
    static let digitalWallet = "DIGITAL_WALLETS_SERVICE"
    static let charity = "CHARITY_SERVICE"
    static let socialAndGame = "SOCIAL_AND_GAMES_SERVICE"
    static let education = "EDUCATION_SERVICE"
    static let security = "SECURITY_SERVICE"
    static let repayment = "REPAYMENT_LOANS_AND_ACCOUNTS_SERVICE"
}

extension String? {
    
    var isLegacyPaymentFlow: Bool {
        
        guard let self else { return true }
        
        return self == ProductStatementData.Kind.mobile ||
               self == ProductStatementData.Kind.taxes
    }
}
