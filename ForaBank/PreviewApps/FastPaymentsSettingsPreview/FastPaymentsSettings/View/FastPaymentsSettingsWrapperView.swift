//
//  FastPaymentsSettingsWrapperView.swift
//  FastPaymentsSettingsPreview
//
//  Created by Igor Malyarov on 11.01.2024.
//

import FastPaymentsSettings
import SwiftUI

struct FastPaymentsSettingsWrapperView: View {
    
    @ObservedObject var viewModel: FastPaymentsSettingsViewModel
    
    let config: FastPaymentsSettingsConfig
    
    var body: some View {
        
        switch viewModel.state.settingsResult {
        case .none, .failure:
            Text("Empty View").opacity(0.1)
            
        case let .success(.contracted(contractDetails)):
            switch contractDetails.paymentContract.contractStatus {
            case .active:
                ActiveContractView(
                    contractDetails: contractDetails,
                    consentListEvent: { viewModel.event(.consentList($0)) }, 
                    productSelectEvent: { viewModel.event(.products($0)) },
                    actionOff: { viewModel.event(.contract(.deactivateContract)) },
                    setBankDefault: { viewModel.event(.bankDefault(.setBankDefault)) },
                    accountLinking: { viewModel.event(.subscription(.getC2BSubButtonTapped)) },
                    config: config.activeContract
                )
                
            case .inactive:
                InactiveContractView(
                    action: { viewModel.event(.contract(.activateContract)) },
                    config: config.inactiveContract
                )
            }
            
        case let .success(.missingContract(consentResult)):
            InactiveContractView(
                action: { viewModel.event(.contract(.activateContract)) },
                config: config.inactiveContract
            )
        }
    }
}

struct FastPaymentsSettingsView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        FastPaymentsSettingsWrapperView(
            viewModel: .preview,
            config: .preview
        )
    }
}
