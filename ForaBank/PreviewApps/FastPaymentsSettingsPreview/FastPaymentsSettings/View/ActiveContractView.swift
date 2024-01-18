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
        
        VStack(spacing: 64) {
            
            VStack(spacing: 16) {
                
                Button("Выключить переводы СБП", action: actionOff)
                
                HStack(spacing: 16) {
                    
                    Text("Переводы включены")
                        .font(.subheadline)
                    
                    ToggleMockView(status: .active)
                }
            }
            
            BankDefaultView(
                bankDefault: contractDetails.bankDefault, 
                action: setBankDefault
            )
        }
    }
}

struct ActiveContractView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        ActiveContractView(
            contractDetails: .preview(),
            actionOff:  {},
            setBankDefault: {}
        )
    }
}
