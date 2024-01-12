//
//  ContentView.swift
//  FastPaymentsSettingsPreview
//
//  Created by Igor Malyarov on 12.01.2024.
//

import SwiftUI

struct ContentView: View {
    
    @State private var flow: Flow = .a1d1
    
    var body: some View {
        
        UserAccountView(viewModel: .preview(
            route: .init(),
            getContractConsentAndDefault: { completion in
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    
                    completion(flow.contractConsentAndDefault)
                }
            },
            updateContract: { _, completion in
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    
                    completion(flow.updateContractResponse)
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
        
        case a1d1, a1d2, a1d3
        case a2d1, a2d2, a2d3
        case a3, a4, a5
    }
}

private extension ContentView.Flow {
    
    var contractConsentAndDefault: ContractConsentAndDefault {
        
        switch self {
        case .a1d1, .a1d2, .a1d3:
            return .active()
            
        case .a2d1, .a2d2, .a2d3:
            return .inactive()
        
        case .a3:
            return .missingContract()
        
        case .a4:
            return .failure(.serverError("Server Error #7654"))
        
        case .a5:
            return .failure(.connectivityError)
        }
    }
    
    var updateContractResponse: FastPaymentsSettingsReducer.UpdateContractResponse {
        
        switch self {
        case .a1d1:
            return .success(.init())

        case .a1d2:
            return .serverError("Server Error #7654")

        case .a1d3:
            return .connectivityError

        case .a2d1:
            return .success(.init())

        case .a2d2:
            return .serverError("Server Error #7654")

        case .a2d3:
            return .connectivityError

        case .a3:
            fatalError("impossible")

        case .a4:
            fatalError("impossible")

        case .a5:
            fatalError("impossible")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        ContentView()
    }
}
