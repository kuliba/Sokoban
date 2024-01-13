//
//  FPSPrototypeView.swift
//  FastPaymentsSettingsPreview
//
//  Created by Igor Malyarov on 12.01.2024.
//

import SwiftUI

struct FPSPrototypeView: View {
    
    @ObservedObject private var viewModel: UserAccountViewModel
    @State private var flow: Flow = .a1c2f1d1
    
    init() {
        
        let flow: Flow = .a1c2f1d1
        let viewModel = UserAccountViewModel.preview(
            route: .init(),
            getUserPaymentSettings: { completion in
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    
                    completion(flow.userPaymentSettings)
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
            },
            prepareSetBankDefault: { completion in
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    
                    completion(flow.prepareSetBankDefaultResponse)
                }
            }
        )
        
        self.flow = flow
        self.viewModel = viewModel
    }
    
    var body: some View {
        
        UserAccountView(viewModel: viewModel)
            .overlay(alignment: .topTrailing, content: picker)
            .overlay(alignment: .bottom, content: overlay)
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
    
    private func overlay() -> some View {
        
        VStack(spacing: 32) {
            
            buttons()
            values()
        }
    }
    
    private func buttons() -> some View {
        
        HStack(spacing: 16) {
            
            showLoaderButton()
            showAlertButton()
            showInformerButton()
        }
        .buttonStyle(.bordered)
    }
    
    private func showLoaderButton() -> some View {
        
        Button("loader", action: viewModel.showDemoLoader)
    }
    
    private func showAlertButton() -> some View {
        
        Button("alert", action: viewModel.showDemoAlert)
    }
    
    private func showInformerButton() -> some View {
        
        Button("informer", action: viewModel.showDemoInformer)
    }
    
    private func values() -> some View {
        
        VStack {
            Text("destination: \(viewModel.route.destination == nil ? "nil" : "value")")
            Text("fpsDestination: \(viewModel.route.fpsDestination == nil ? "nil" : "value")")
            Text("modal: \(viewModel.route.modal == nil ? "nil" : "value")")
            Text("isLoading: \(viewModel.route.isLoading ? "true" : "false")")
            Text("informer: \(viewModel.informer.informer?.text == nil ? "nil" : "value")")
        }
        .foregroundStyle(.secondary)
        .font(.footnote)
    }
}

private extension FPSPrototypeView {
    
    enum Flow: String, CaseIterable {
        
        case a1c1d1, a1c1d2, a1c1d3
        case a1c2f1d1, a1c2f1d2, a1c2f1d3
        case a1c2f2d1, a1c2f2d2, a1c2f2d3
        case a1c2f3d1, a1c2f3d2, a1c2f3d3
        case a2d1, a2d2, a2d3
        case a3ea1, a3ea2, a3ea3, a3nil
        case a4, a5
    }
}

private extension FPSPrototypeView.Flow {
    
    var userPaymentSettings: UserPaymentSettings {
        
        switch self {
        case .a1c1d1, .a1c1d2, .a1c1d3:
            return .active(bankDefault: .onDisabled)
            
        case .a1c2f1d1, .a1c2f1d2, .a1c2f1d3:
            return .active(bankDefault: .offEnabled)
            
        case .a1c2f2d1, .a1c2f2d2, .a1c2f2d3:
            return .active(bankDefault: .offEnabled)
            
        case .a1c2f3d1, .a1c2f3d2, .a1c2f3d3:
            return .active(bankDefault: .offEnabled)
            
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
        case .a1c1d1, .a1c2f1d1:
            return .success(.active)
            
        case .a1c2f2d1, .a1c2f2d2, .a1c2f2d3:
            fatalError("impossible")
        case .a1c2f3d1, .a1c2f3d2, .a1c2f3d3:
            fatalError("impossible")
            
        case .a1c1d2, .a1c2f1d2:
            return .serverError("Server Error #7654")
            
        case .a1c1d3, .a1c2f1d3:
            return .connectivityError
            
        case .a2d1:
            return .success(.inactive)
            
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
        case .a1c1d1, .a1c2f1d1:
            fatalError("impossible")
        case .a1c2f2d1, .a1c2f2d2, .a1c2f2d3:
            fatalError("impossible")
        case .a1c2f3d1, .a1c2f3d2, .a1c2f3d3:
            fatalError("impossible")
        case .a1c1d2, .a1c2f1d2:
            fatalError("impossible")
        case .a1c1d3, .a1c2f1d3:
            fatalError("impossible")
        case .a2d1:
            fatalError("impossible")
        case .a2d2:
            fatalError("impossible")
        case .a2d3:
            fatalError("impossible")
            
        case .a3ea1, .a3ea2, .a3ea3:
            return .init(id: .init(UUID().uuidString))
            
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
        case .a1c1d1, .a1c2f1d1:
            fatalError("impossible")
        case .a1c2f2d1, .a1c2f2d2, .a1c2f2d3:
            fatalError("impossible")
        case .a1c2f3d1, .a1c2f3d2, .a1c2f3d3:
            fatalError("impossible")
        case .a1c1d2, .a1c2f1d2:
            fatalError("impossible")
        case .a1c1d3, .a1c2f1d3:
            fatalError("impossible")
        case .a2d1:
            fatalError("impossible")
        case .a2d2:
            fatalError("impossible")
        case .a2d3:
            fatalError("impossible")
            
        case .a3ea1:
            return .success(.active)
            
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
    
    var prepareSetBankDefaultResponse: FastPaymentsSettingsReducer.PrepareSetBankDefaultResponse {
        
        switch self {
        case .a1c1d1:
            fatalError("impossible")
        case .a1c1d2:
            fatalError("impossible")
        case .a1c1d3:
            fatalError("impossible")
            
        case .a1c2f1d1, .a1c2f1d2, .a1c2f1d3:
            return .success
            
        case .a1c2f2d1, .a1c2f2d2, .a1c2f2d3:
            return .serverError("Возникла техническая ошибка (код 4044). Свяжитесь с поддержкой банка для уточнения")
            
        case .a1c2f3d1, .a1c2f3d2, .a1c2f3d3:
            return .connectivityError
            
        case .a2d1:
            fatalError("impossible")
        case .a2d2:
            fatalError("impossible")
        case .a2d3:
            fatalError("impossible")
        case .a3ea1:
            fatalError("impossible")
        case .a3ea2:
            fatalError("impossible")
        case .a3ea3:
            fatalError("impossible")
        case .a3nil:
            fatalError("impossible")
        case .a4:
            fatalError("impossible")
        case .a5:
            fatalError("impossible")
        }
    }
}

struct FPSPrototypeView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        FPSPrototypeView()
    }
}
