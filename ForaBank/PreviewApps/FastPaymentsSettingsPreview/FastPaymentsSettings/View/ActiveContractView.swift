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
    let actionOff: () -> Void
    let setBankDefault: () -> Void
    
    var body: some View {
        
        List {
            
            PaymentContractView(
                paymentContract: contractDetails.paymentContract, 
                actionOff: actionOff
            )
            
            BankDefaultView(
                bankDefault: contractDetails.bankDefault,
                action: setBankDefault
            )
        }
    }
}

struct ActiveContractView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        VStack(spacing: 32) {
            
            activeContractView(.preview(paymentContract: .active))
            
            Divider()
            
            activeContractView(.preview(paymentContract: .inactive))
        }
    }
    
    private static func activeContractView(
        _ contractDetails: UserPaymentSettings.ContractDetails
    ) -> some View {
        
        ActiveContractView(
            contractDetails: contractDetails,
            actionOff:  {},
            setBankDefault: {}
        )
    }
}
