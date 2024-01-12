//
//  ActiveContractView.swift
//  FastPaymentsSettingsPreview
//
//  Created by Igor Malyarov on 12.01.2024.
//

import SwiftUI

struct ActiveContractView: View {
    
    let contractDetails: ContractConsentAndDefault.ContractDetails
    let action: () -> Void
    
    var body: some View {
        
        VStack {
            
            HStack(spacing: 16) {
                
                Color.green
                    .clipShape(.circle)
                    .frame(width: 64, height: 64)
                
                Button("Выключить переводы СБП", action: action)
            }
            
            bankDefaultView(contractDetails.bankDefault)
        }
    }
    
    @ViewBuilder
    private func bankDefaultView(
        _ bankDefault: ContractConsentAndDefault.BankDefault
    ) -> some View {
        
        HStack {
            bankDefaultIcon(bankDefault)
            
            Text("ForaBank")
        }
    }
    
    @ViewBuilder
    private func bankDefaultIcon(
        _ bankDefault: ContractConsentAndDefault.BankDefault
    ) -> some View {
        
        switch bankDefault {
        case .onDisabled:
            Color.green.opacity(0.3)
                .clipShape(.circle)
                .frame(width: 32, height: 32)
            
        case .offEnabled:
            Button(action: {}) {
                Color.black
                    .clipShape(.circle)
                    .frame(width: 32, height: 32)
            }
            
        case .offDisabled:
            Color.black.opacity(0.4)
                .clipShape(.circle)
                .frame(width: 32, height: 32)
        }
    }
}

struct ActiveContractView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        ActiveContractView(
            contractDetails: .preview(),
            action:  {}
        )
    }
}
