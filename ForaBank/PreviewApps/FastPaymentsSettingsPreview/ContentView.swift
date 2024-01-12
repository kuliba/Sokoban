//
//  ContentView.swift
//  FastPaymentsSettingsPreview
//
//  Created by Igor Malyarov on 12.01.2024.
//

import SwiftUI

struct ContentView: View {
    
    @State private var flow: Flow = .a3ea3
    
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
            },
            getProduct: { flow.product },
            createContract: { _, completion in
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    
                    completion(flow.createContractResponse)
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
        case a3ea1, a3ea2, a3ea3, a3nil
        case a4, a5
    }
}

private extension ContentView.Flow {
    
    var contractConsentAndDefault: ContractConsentAndDefault {
        
        switch self {
        case .a1d1, .a1d2, .a1d3:
            return .active()
            
        case .a2d1, .a2d2, .a2d3:
            return .inactive()
        
        case .a3ea1, .a3ea2, .a3ea3, .a3nil:
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

        case .a3ea1, .a3ea2, .a3ea3, .a3nil:
            fatalError("impossible")
        case .a4:
            fatalError("impossible")
        case .a5:
            fatalError("impossible")
        }
    }
    
    var product: FastPaymentsSettingsReducer.Product? {
        
        switch self {
        case .a1d1:
            fatalError("impossible")
        case .a1d2:
            fatalError("impossible")
        case .a1d3:
            fatalError("impossible")
        case .a2d1:
            fatalError("impossible")
        case .a2d2:
            fatalError("impossible")
        case .a2d3:
            fatalError("impossible")
        
        case .a3ea1, .a3ea2, .a3ea3:
            return .init(id: UUID().uuidString)
        
        case .a3nil:
            return nil
        
        case .a4:
            fatalError("impossible")
        case .a5:
            fatalError("impossible")
        }
    }
    
    var createContractResponse: FastPaymentsSettingsReducer.CreateContractResponse {
        
        switch self {
        case .a1d1:
            fatalError("impossible")
        case .a1d2:
            fatalError("impossible")
        case .a1d3:
            fatalError("impossible")
        case .a2d1:
            fatalError("impossible")
        case .a2d2:
            fatalError("impossible")
        case .a2d3:
            fatalError("impossible")

        case .a3ea1:
            return .success(.init())
            
        case .a3ea2:
            return .serverError("Возникла техническая ошибка (код 4044). Свяжитесь с поддержкой банка для уточнения")
            
        case .a3ea3:
            return .connectivityError
            
        case .a3nil:
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
