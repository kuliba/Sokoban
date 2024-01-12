//
//  ContentView.swift
//  FastPaymentsSettingsPreview
//
//  Created by Igor Malyarov on 12.01.2024.
//

import SwiftUI

struct ContentView: View {
    
    @State private var flow: Flow = .a1
    
    var body: some View {
        
        UserAccountView(viewModel: .preview(
            route: .init(),
            getContractConsentAndDefault: { completion in
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                    
                    completion(flow.contractConsentAndDefault)
                }
            }
        ))
        .overlay(alignment: .topTrailing, content: picker)
    }
    
    private func picker() -> some View {
        
        Picker("Select Flow", selection: $flow) {
            
            ForEach(Flow.allCases, id: \.self) {
                
                Text($0.rawValue)
                    .tag($0)
            }
        }
        .pickerStyle(.menu)
    }
}

private extension ContentView {
    
    enum Flow: String, CaseIterable {
        
        case a1, a2, a3, a4, a5
    }
}

private extension ContentView.Flow {
    
    var contractConsentAndDefault: ContractConsentAndDefault {
        
        switch self {
        case .a1:
            return .active()
        case .a2:
            return .inactive()
        case .a3:
            return .missingContract()
        case .a4:
            return .serverError
        case .a5:
            return .connectivityError
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        ContentView()
    }
}
