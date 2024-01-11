//
//  FastPaymentsSettingsView.swift
//  FastPaymentsSettingsPreview
//
//  Created by Igor Malyarov on 11.01.2024.
//

import SwiftUI

struct FastPaymentsSettingsView: View {
    
    @ObservedObject var viewModel: FastPaymentsSettingsViewModel
    
    var body: some View {
        
        Group {
            
            switch viewModel.state {
            case .none:
                Text("Empty View").opacity(0.2)
                
            case let .contractConsentAndDefault(contractConsentAndDefault):
                switch contractConsentAndDefault {
                case let .active(contractDetails):
                    Text("Active.\n\nContractDetails: \(String(describing: contractDetails))")
                        .foregroundStyle(.green)
                    
                case let .inactive(contractDetails):
                    Text("Inactive.\n\nContractDetails: \(String(describing: contractDetails))")
                    
                case let .missingContract(consentResult):
                    Text("Missing Contract.\n\n\(String(describing: consentResult))")
                    
                case let .serverError(message):
                    Text("Here should be alert for message: \(message)")
                        .foregroundStyle(.red)
                    
                case .connectivityError:
                    Text("Here should be alert for connectivityError.")
                        .foregroundStyle(.red)
                }
            }
        }
        .padding()
    }
}

struct FastPaymentsSettingsView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        FastPaymentsSettingsView(viewModel: .preview)
    }
}
