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
            
            switch viewModel.state?.contractConsentAndDefault {
            case .none, .serverError, .connectivityError:
                Text("Empty View").opacity(0.1)
                
            case let .active(contractDetails):
                Text("Active.\n\nContractDetails: \(String(describing: contractDetails))")
                    .foregroundStyle(.green)
                
            case let .inactive(contractDetails):
                #warning("extract to separate view")
                Button("Включить переводы СБП") {
                    
                    viewModel.event(.activateContract)
                }
                
            case let .missingContract(consentResult):
                Text("Missing Contract.\n\n\(String(describing: consentResult))")
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
