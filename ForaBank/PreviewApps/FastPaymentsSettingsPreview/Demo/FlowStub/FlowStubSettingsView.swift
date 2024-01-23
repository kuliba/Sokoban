//
//  FlowStubSettingsView.swift
//  FastPaymentsSettingsPreview
//
//  Created by Igor Malyarov on 18.01.2024.
//

import FastPaymentsSettings
import SwiftUI

typealias Pickerable = RawRepresentable & CaseIterable & Identifiable & Hashable

struct FlowStubSettingsView: View {
    
    @State private var getProducts: GetProducts?
    @State private var createContract: CreateContractResponse?
    @State private var getSettings: GetSettings?
    @State private var prepareSetBankDefault: PrepareSetBankDefault?
    @State private var updateContract: UpdateContract?
    @State private var updateProduct: UpdateProduct?
    
    private let commit: (FlowStub) -> Void
    
    init(
        flowStub: FlowStub?,
        commit: @escaping (FlowStub) -> Void
    ) {
        self.commit = commit
        self._getProducts = .init(initialValue: .init(flowStub: flowStub))
        self._createContract = .init(initialValue: .init(flowStub: flowStub))
        self._getSettings = .init(initialValue: .init(flowStub: flowStub))
        self._prepareSetBankDefault = .init(initialValue: .init(flowStub: flowStub))
        self._updateContract = .init(initialValue: .init(flowStub: flowStub))
        self._updateProduct = .init(initialValue: .init(flowStub: flowStub))
    }
    
    var body: some View {
        
        List {
            
            pickerSection("Products", selection: $getProducts)
            pickerSection("Create Contract", selection: $createContract)
            pickerSection("Get Settings", selection: $getSettings)
            pickerSection("Prepare Set Bank Default", selection: $prepareSetBankDefault)
            pickerSection("Update Contract", selection: $updateContract)
            pickerSection("Update Product", selection: $updateProduct)
        }
        .listStyle(.plain)
        .overlay(alignment: .bottom, content: buttons)
        .navigationTitle("Select Results for Requests")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private var flowStub: FlowStub? {
        
        guard let getProducts = getProducts?.products,
              let createContract = createContract?.response,
              let getSettings = getSettings?.settings,
              let prepareSetBankDefault = prepareSetBankDefault?.prepareSetBankDefaultResponse,
              let updateContract = updateContract?.updateContractResponse,
              let updateProduct = updateProduct?.updateProductResponse
        else { return nil }
        
        return .init(
            getProducts: getProducts,
            createContract: createContract,
            getSettings: getSettings,
            prepareSetBankDefault: prepareSetBankDefault,
            updateContract: updateContract,
            updateProduct: updateProduct)
    }
    
    private func pickerSection<T: Pickerable>(
        _ title: String,
        selection: Binding<T?>
    ) -> some View where T.RawValue == String, T.AllCases: RandomAccessCollection {
        
        Section(title) {
            
            Picker(title, selection: selection) {
                
                ForEach(T.allCases) {
                    
                    Text($0.rawValue)
                        .tag(Optional($0))
                }
            }
            .pickerStyle(.segmented)
        }
    }
    
    private func buttons() -> some View {
        
        VStack(spacing: 16) {
            
            Button("Happy Path") {
                
                getProducts = .init(flowStub: .preview)
                createContract = .init(flowStub: .preview)
                getSettings = .init(flowStub: .preview)
                prepareSetBankDefault = .init(flowStub: .preview)
                updateContract = .init(flowStub: .preview)
                updateProduct = .init(flowStub: .preview)
            }
            
            Button {
                flowStub.map(commit)
            } label: {
                Text("Apply")
                    .font(.headline)
                    .padding(.vertical, 9)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .disabled(flowStub == nil)
        }
        .padding(.horizontal)
    }
}

private extension FlowStubSettingsView {
    
    enum GetProducts: String, CaseIterable, Identifiable {
        
        case empty, preview
        
        var id: Self { self }
        
        var products: [Product] {
            
            switch self {
            case .empty:   return []
            case .preview: return .preview
            }
        }
    }
    
    enum CreateContractResponse: String, CaseIterable, Identifiable {
        
        case active, inactive, error_C, error_S
        
        var id: Self { self }
        
        var response: ContractEffectHandler.CreateContractResponse {
            
            switch self {
            case .active:   return .success(.active)
            case .inactive: return .success(.inactive)
            case .error_C:  return .failure(.connectivityError)
            case .error_S:  return .failure(.serverError(UUID().uuidString))
            }
        }
    }
    
    enum GetSettings: String, CaseIterable, Identifiable {
        
        case active, inactive, missing, error_C, error_S
        
        var id: Self { self }
        
        var settings: UserPaymentSettings {
            
            switch self {
            case .active:
                return .contracted(.preview(paymentContract: .active))
                
            case .inactive:
                return .contracted(.preview(paymentContract: .inactive))
            case .missing:
                return .missingContract()
                
            case .error_C:
                return .failure(.connectivityError)
                
            case .error_S:
                return .failure(.serverError(UUID().uuidString))
            }
        }
    }
    
    enum PrepareSetBankDefault: String, CaseIterable, Identifiable {
        
        case success, error_C, error_S
        
        var id: Self { self }
        
        var prepareSetBankDefaultResponse: FastPaymentsSettingsEffectHandler.PrepareSetBankDefaultResponse {
            
            switch self {
            case .success: return .success(())
            case .error_C: return .failure(.connectivityError)
            case .error_S: return .failure(.serverError(UUID().uuidString))
            }
        }
    }
    
    enum UpdateContract: String, CaseIterable, Identifiable {
        
        case active, inactive, error_C, error_S
        
        var id: Self { self }
        
        var updateContractResponse: ContractEffectHandler.UpdateContractResponse {
            
            switch self {
            case .active:   return .success(.active)
            case .inactive: return .success(.inactive)
            case .error_C:  return .failure(.connectivityError)
            case .error_S:  return .failure(.serverError(UUID().uuidString))
            }
        }
    }
    
    enum UpdateProduct: String, CaseIterable, Identifiable {
        
        case success, error_C, error_S
        
        var id: Self { self }
        
        var updateProductResponse: FastPaymentsSettingsEffectHandler.UpdateProductResponse {
            
            switch self {
            case .success: return .success(())
            case .error_C: return .failure(.connectivityError)
            case .error_S: return .failure(.serverError(UUID().uuidString))
            }
        }
    }
}

private extension FlowStubSettingsView.GetProducts {
    
    init?(flowStub: FlowStub?) {
        
        guard let products = flowStub?.getProducts
        else { return nil }
        
        if products.isEmpty {
            self = .empty
        } else {
            self = .preview
        }
    }
}

private extension FlowStubSettingsView.CreateContractResponse {
    
    init?(flowStub: FlowStub?) {
        
        switch flowStub?.createContract {
        case .none:
            return nil
            
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
    
    init?(flowStub: FlowStub?) {
        
        switch flowStub?.getSettings {
        case .none:
            return nil
            
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
    
    init?(flowStub: FlowStub?) {
        
        switch flowStub?.prepareSetBankDefault {
        case .none:
            return nil
            
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

private extension FlowStubSettingsView.UpdateContract {
    
    init?(flowStub: FlowStub?) {
        
        switch flowStub?.updateContract {
        case .none:
            return nil
            
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

private extension FlowStubSettingsView.UpdateProduct {
    
    init?(flowStub: FlowStub?) {
        
        switch flowStub?.updateProduct {
        case .none:
            return nil
            
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
        updateContract: .success(.inactive),
        updateProduct: .success(())
    )
}
