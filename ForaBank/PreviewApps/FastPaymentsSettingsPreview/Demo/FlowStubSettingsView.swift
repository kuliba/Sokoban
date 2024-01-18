//
//  FlowStubSettingsView.swift
//  FastPaymentsSettingsPreview
//
//  Created by Igor Malyarov on 18.01.2024.
//

import FastPaymentsSettings
import SwiftUI

struct FlowStubSettingsView: View {
    
    @State private var getProducts: GetProducts?
    @State private var createContract: CreateContractResponse?
    @State private var getSettings: GetSettings?
    @State private var prepareSetBankDefault: PrepareSetBankDefault?
    
    private let commit: (FlowStub) -> Void
    
    init(
        flowStub: FlowStub?,
        commit: @escaping (FlowStub) -> Void
    ) {
        self.commit = commit
        self.getProducts = flowStub.map { .init(flowStub: $0) }
        self.createContract = flowStub.map { .init(flowStub: $0) }
        self.getSettings = flowStub.map { .init(flowStub: $0) }
        self.prepareSetBankDefault = flowStub.map { .init(flowStub: $0) }
    }
    
    private var flowStub: FlowStub? {
        
        nil
    }
    
    var body: some View {
        
        Form {
            
            getProductsPicker()
            createContractPicker()
            getSettingsPicker()
            prepareSetBankDefaultPicker()
        }
        .overlay(alignment: .bottom, content: applyButton)
        .navigationTitle("Select  Flow Options")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func getProductsPicker() -> some View {
        
        VStack(alignment: .leading) {
            
            Text("Select products").font(.footnote)
            
            Picker("Select products", selection: $getProducts) {
                
                ForEach(GetProducts.allCases) {
                    
                    Text($0.rawValue)
                        .tag(Optional($0))
                }
            }
            .pickerStyle(.segmented)
        }
    }
    
    private func createContractPicker() -> some View {
        
        VStack(alignment: .leading) {
            
            Text("Create Contract Result").font(.footnote)
            
            Picker("Create Contract Result", selection: $createContract) {
                
                ForEach(CreateContractResponse.allCases) {
                    
                    Text($0.rawValue)
                        .tag(Optional($0))
                }
            }
            .pickerStyle(.segmented)
        }
    }
    
    private func getSettingsPicker() -> some View {
        
        VStack(alignment: .leading) {
            
            Text("Get Settings Result").font(.footnote)
            
            Picker("Get Settings Result", selection: $getSettings) {
                
                ForEach(GetSettings.allCases) {
                    
                    Text($0.rawValue)
                        .tag(Optional($0))
                }
            }
            .pickerStyle(.segmented)
        }
    }
    
    private func prepareSetBankDefaultPicker() -> some View {
        
        VStack(alignment: .leading) {
            
            Text("Prepare Set Bank Default Result").font(.footnote)
            
            Picker("Prepare Set Bank Default Result", selection: $prepareSetBankDefault) {
                
                ForEach(PrepareSetBankDefault.allCases) {
                    
                    Text($0.rawValue)
                        .tag(Optional($0))
                }
            }
            .pickerStyle(.segmented)
        }
    }
    
    private func applyButton() -> some View {
        
        Button {
            
        } label: {
            Text("Apply")
                .font(.headline)
                .padding(.vertical, 9)
                .frame(maxWidth: .infinity)
        }
        .padding(.horizontal)
        .buttonStyle(.borderedProminent)
        .disabled(flowStub == nil)
    }
}

private extension FlowStubSettingsView {
    
    enum GetProducts: String, CaseIterable, Identifiable {
        
        case empty, preview
        
        var id: Self { self }
    }
    
    enum CreateContractResponse: String, CaseIterable, Identifiable {
        
        case active, inactive, error_C, error_S
        
        var id: Self { self }
        
        var response: FastPaymentsSettingsEffectHandler.CreateContractResponse {
            
            switch self {
            case .active:       return .success(.active)
            case .inactive:     return .success(.inactive)
            case .error_C: return .failure(.connectivityError)
            case .error_S:       return .failure(.serverError(UUID().uuidString))
            }
        }
    }
    
    enum GetSettings: String, CaseIterable, Identifiable {
        
        case active, inactive, missing, error_C, error_S
        
        var id: Self { self }
    }
    
    enum PrepareSetBankDefault: String, CaseIterable, Identifiable {
        
        case success, error_C, error_S
        
        var id: Self { self }
    }
}

private extension FlowStubSettingsView.GetProducts {
    
    init(flowStub: FlowStub) {
        
        if flowStub.getProducts.isEmpty {
            self = .empty
        } else {
            self = .preview
        }
    }
}

private extension FlowStubSettingsView.CreateContractResponse {
    
    init(flowStub: FlowStub) {
        
        switch flowStub.createContract {
        case let .success(contract):
            switch contract.contractStatus {
            case .active:
                self = .active
            case .inactive:
                self = .inactive
            }
            
        case let .failure(failure):
            switch failure {
            case .connectivityError:
                self = .error_C
                
            case .serverError:
                self = .error_S
            }
        }
    }
}

private extension FlowStubSettingsView.GetSettings {
    
    init(flowStub: FlowStub) {
        
        switch flowStub.getSettings {
        case let .contracted(contractDetails):
            switch contractDetails.paymentContract.contractStatus {
            case .active:
                self = .active
                
            case .inactive:
                self = .inactive
            }
            
        case .missingContract:
            self = .missing
            
        case let .failure(failure):
            switch failure {
            case .connectivityError:
                self = .error_C
                
            case .serverError:
                self = .error_S
            }
        }
    }
}

private extension FlowStubSettingsView.PrepareSetBankDefault {
    
    init(flowStub: FlowStub) {
        
        switch flowStub.prepareSetBankDefault {
        case .success(()):
            self = .success
            
        case let .failure(failure):
            switch failure {
            case .connectivityError:
                self = .error_C
                
            case .serverError:
                self = .error_S
            }
        }
    }
}

struct FlowStubSettingsView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        flowStubSettingsView(nil)
        flowStubSettingsView(.preview)
    }
    
    private static func flowStubSettingsView(
        _ flowStub: FlowStub?
    ) -> some View {
        
        NavigationView {
            
            FlowStubSettingsView(flowStub: flowStub, commit: { _ in })
        }
    }
}

extension FlowStub {
    
    static let preview: Self = .init(
        getProducts: .preview,
        createContract:  .success(.active),
        getSettings: .contracted(.preview()),
        prepareSetBankDefault: .success(()),
        updateContract: .success(.active),
        updateProduct: .success(())
    )
}
