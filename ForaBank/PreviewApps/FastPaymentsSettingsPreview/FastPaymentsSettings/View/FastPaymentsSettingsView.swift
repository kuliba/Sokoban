//
//  FastPaymentsSettingsView.swift
//  FastPaymentsSettingsPreview
//
//  Created by Igor Malyarov on 11.01.2024.
//

import FastPaymentsSettings
import SwiftUI

struct FastPaymentsSettingsView: View {
    
    @ObservedObject var viewModel: FastPaymentsSettingsViewModel
    
    var body: some View {
        
        switch viewModel.state.userPaymentSettings {
        case .none, .failure:
            Text("Empty View").opacity(0.1)
            
        case let .contracted(contractDetails):
            switch contractDetails.paymentContract.contractStatus {
            case .active:
                ActiveContractView(
                    contractDetails: contractDetails,
                    actionOff: { viewModel.event(.contract(.deactivateContract)) },
                    setBankDefault: { viewModel.event(.bankDefault(.setBankDefault)) }
                )
                
            case .inactive:
                InactiveContractView {
                    
                    viewModel.event(.contract(.activateContract))
                }
            }
            
        case let .missingContract(consentResult):
            VStack(spacing: 32) {
                
                Text("Missing Payment Contract.\n\n\(String(describing: consentResult))")
                
                HStack(spacing: 16) {
                    
                    Color.black
                        .clipShape(.circle)
                        .frame(width: 64, height: 64)
                    
                    Button("Включить переводы СБП") {
                        
                        viewModel.event(.contract(.activateContract))
                    }
                }
            }
        }
    }
}

struct FastPaymentsSettingsView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        FastPaymentsSettingsView(viewModel: .preview)
    }
}
