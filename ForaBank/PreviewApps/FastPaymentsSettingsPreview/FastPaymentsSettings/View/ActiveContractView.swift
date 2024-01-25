//
//  ActiveContractView.swift
//  FastPaymentsSettingsPreview
//
//  Created by Igor Malyarov on 12.01.2024.
//

import FastPaymentsSettings
import SwiftUI

struct ActiveContractView: View {
    
    let contractDetails: UserPaymentSettings.ContractDetails
    #warning("combine event closures into one closure")
    let consentListEvent: (ConsentListEvent) -> Void
    let actionOff: () -> Void
    let setBankDefault: () -> Void
    
    var body: some View {
        
        List {
            
            PaymentContractView(
                paymentContract: contractDetails.paymentContract, 
                actionOff: actionOff
            )
            
            ConsentListView(
                state: contractDetails.consentList.uiState,
                event: consentListEvent
            )
            
            BankDefaultView(
                bankDefault: contractDetails.bankDefault,
                action: setBankDefault
            )
            
            // productSelector
        }
    }
}

struct ActiveContractView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        Group {
            
            activeContractView(.preview(paymentContract: .active))
            activeContractView(.preview(paymentContract: .inactive))
        }
    }
    
    private static func activeContractView(
        _ contractDetails: UserPaymentSettings.ContractDetails
    ) -> some View {
        
        ActiveContractView(
            contractDetails: contractDetails,
            consentListEvent: { _ in },
            actionOff:  {},
            setBankDefault: {}
        )
    }
}
