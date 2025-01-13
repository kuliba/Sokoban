//
//  FlowStubSettingsView.swift
//  FastPaymentsSettingsPreview
//
//  Created by Igor Malyarov on 18.01.2024.
//

import FastPaymentsSettings
import OTPInputComponent
import SwiftUI

typealias Pickerable = RawRepresentable & CaseIterable & Identifiable & Hashable

struct FlowStubSettingsView: View {
    
    @State private var getProducts: GetProducts?
    @State private var changeConsentList: ChangeConsentList?
    @State private var createContract: CreateContract?
    @State private var getC2BSub: GetC2BSub?
    @State private var getSettings: GetSettings?
    @State private var prepareSetBankDefault: PrepareSetBankDefault?
    @State private var updateContract: UpdateContract?
    @State private var updateProduct: UpdateProduct?
    @State private var initiateOTP: InitiateOTP?
    @State private var submitOTP: SubmitOTP?
    
    private let commit: (FlowStub) -> Void
    
    init(
        flowStub: FlowStub?,
        commit: @escaping (FlowStub) -> Void
    ) {
        self.commit = commit
        self._getProducts = .init(initialValue: .init(flowStub: flowStub))
        self._changeConsentList = .init(initialValue: .init(flowStub: flowStub))
        self._createContract = .init(initialValue: .init(flowStub: flowStub))
        self._getC2BSub = .init(initialValue: .init(flowStub: flowStub))
        self._getSettings = .init(initialValue: .init(flowStub: flowStub))
        self._prepareSetBankDefault = .init(initialValue: .init(flowStub: flowStub))
        self._updateContract = .init(initialValue: .init(flowStub: flowStub))
        self._updateProduct = .init(initialValue: .init(flowStub: flowStub))
        self._initiateOTP = .init(initialValue: .init(flowStub: flowStub))
        self._submitOTP = .init(initialValue: .init(flowStub: flowStub))
    }
    
    var body: some View {
        
        VStack {
            
            List {
                
                pickerSection("Get Settings (flow \"abc\")", selection: $getSettings)
                pickerSection("Products", selection: $getProducts)
                pickerSection("Change Consent List", selection: $changeConsentList)
                pickerSection("Create Contract", selection: $createContract)
                pickerSection("Prepare Set Bank Default", selection: $prepareSetBankDefault)
                pickerSection("Update Contract", selection: $updateContract)
                pickerSection("Update Product", selection: $updateProduct)
                pickerSection("Initiate OTP", selection: $initiateOTP)
                pickerSection("Submit OTP", selection: $submitOTP)
                pickerSection("Get C2B Subscriptions", selection: $getC2BSub)
            }
            .listStyle(.plain)
            
            applyButton()
        }
        .navigationTitle("Select Results for Requests")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(content: happyPathButton)
    }
    
    private var flowStub: FlowStub? {
        
        guard let getProducts = getProducts?.products,
              let changeConsentList = changeConsentList?.response,
              let createContract = createContract?.response,
              let getC2BSub = getC2BSub?.settings,
              let getSettings = getSettings?.settingsResult,
              let prepareSetBankDefault = prepareSetBankDefault?.prepareSetBankDefaultResponse,
              let updateContract = updateContract?.updateContractResponse,
              let updateProduct = updateProduct?.updateProductResponse,
              let initiateOTP = initiateOTP?.initiateOTPResult,
              let submitOTP = submitOTP?.submitOTPResult
        else { return nil }
        
        return .init(
            getProducts: getProducts,
            changeConsentList: changeConsentList,
            createContract: createContract,
            getC2BSub: getC2BSub,
            getSettings: getSettings,
            prepareSetBankDefault: prepareSetBankDefault,
            updateContract: updateContract,
            updateProduct: updateProduct,
            initiateOTP: initiateOTP,
            submitOTP: submitOTP
        )
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
    
    private func happyPathButton() -> some View {
        
        Button("Happy Path") {
            
            getProducts = .init(flowStub: .preview)
            changeConsentList = .init(flowStub: .preview)
            createContract = .init(flowStub: .preview)
            getC2BSub = .init(flowStub: .preview)
            getSettings = .init(flowStub: .preview)
            prepareSetBankDefault = .init(flowStub: .preview)
            updateContract = .init(flowStub: .preview)
            updateProduct = .init(flowStub: .preview)
            initiateOTP = .init(flowStub: .preview)
            submitOTP = .init(flowStub: .preview)
        }
        .buttonStyle(.bordered)
        .tint(.green)
    }
    
    private func applyButton() -> some View {
        
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
    
    enum ChangeConsentList: String, CaseIterable, Identifiable {
        
        case success, error_C, error_S
        
        var id: Self { self }
        
        var response: ConsentListRxEffectHandler.ChangeConsentListResponse {
            
            switch self {
            case .success: return .success
            case .error_C:  return .connectivityError
            case .error_S:  return .serverError("Server Error Failure Message (#8765).")
            }
        }
    }
    
    enum CreateContract: String, CaseIterable, Identifiable {
        
        case active, inactive, error_C, error_S
        
        var id: Self { self }
        
        var response: ContractEffectHandler.CreateContractResult {
            
            switch self {
            case .active:   return .success(.active)
            case .inactive: return .success(.inactive)
            case .error_C:  return .failure(.connectivityError)
            case .error_S:  return .failure(.serverError("Server Error Failure Message (#8765)."))
            }
        }
    }
    
    enum GetC2BSub: String, CaseIterable, Identifiable {
        
        case control, empty, error_C, error_S
        
        var id: Self { self }
        
        var settings: FastPaymentsSettingsEffectHandler.GetC2BSubResult {
            
            switch self {
            case .control:
                return .success(.control)
            
            case .empty:
                return .success(.empty)
                
            case .error_C:
                return .failure(.connectivityError)
                
            case .error_S:
                return .failure(.serverError("Server Error Failure Message (#8765)."))
            }
        }
    }
    
    enum GetSettings: String, CaseIterable, Identifiable {
        
        case active, limit, inactive, missing, error_C, error_S
        
        var id: Self { self }
        
        var settingsResult: UserPaymentSettingsResult {
            
            switch self {
            case .active:
                return .success(.contracted(.preview(
                    paymentContract: .active
                )))
                
            case .limit:
                return .success(.contracted(.preview(
                    paymentContract: .active,
                    bankDefaultResponse: .init(
                        bankDefault: .offEnabled,
                        requestLimitMessage: "Исчерпан лимит запросов.\nПовторите попытку через 24 часа."
                    )
                )))
                
            case .inactive:
                return .success(.contracted(.preview(paymentContract: .inactive)))
                
            case .missing:
                return .success(.missingContract())
                
            case .error_C:
                return .failure(.connectivityError)
                
            case .error_S:
                return .failure(.serverError("Server Error Failure Message (#8765)."))
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
            case .error_S: return .failure(.serverError("Server Error Failure Message (#8765)."))
            }
        }
    }
    
    enum UpdateContract: String, CaseIterable, Identifiable {
        
        case active, inactive, error_C, error_S
        
        var id: Self { self }
        
        var updateContractResponse: ContractEffectHandler.UpdateContractResult {
            
            switch self {
            case .active:   return .success(.active)
            case .inactive: return .success(.inactive)
            case .error_C:  return .failure(.connectivityError)
            case .error_S:  return .failure(.serverError("Server Error Failure Message (#8765)."))
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
            case .error_S: return .failure(.serverError("Server Error Failure Message (#8765)."))
            }
        }
    }
    
    enum InitiateOTP: String, CaseIterable, Identifiable {
        
        case success, error_C, error_S
        
        var id: Self { self }
        
        var initiateOTPResult: CountdownEffectHandler.InitiateOTPResult {
            
            switch self {
            case .success: return .success(())
            case .error_C: return .failure(.connectivityError)
            case .error_S: return .failure(.serverError("Server Error Failure Message (#8765)."))
            }
        }
    }
    
    enum SubmitOTP: String, CaseIterable, Identifiable {
        
        case success, error_C, incorrect, error_S
        
        var id: Self { self }
        
        var submitOTPResult: OTPFieldEffectHandler.SubmitOTPResult {
            
            switch self {
            case .success: return .success(())
            case .error_C: return .failure(.connectivityError)
            case .incorrect: return .failure(.serverError("Введен некорректный код. Попробуйте еще раз"))
            case .error_S: return .failure(.serverError("Server Error Failure Message (#8765)."))
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

private extension FlowStubSettingsView.ChangeConsentList {
    
    init?(flowStub: FlowStub?) {
        
        switch flowStub?.changeConsentList {
        case .none:
            return nil
            
        case .success:
            self = .success
            
        case .connectivityError:
            self = .error_C
            
        case .serverError:
            self = .error_S
        }
    }
}

private extension FlowStubSettingsView.CreateContract {
    
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

private extension FlowStubSettingsView.GetC2BSub {
    
    init?(flowStub: FlowStub?) {
        
        switch flowStub?.getC2BSub {
        case .none:
            return nil
            
        case let .success(success):
            switch success.details {
            case .list:
                self = .control
                
            case .empty:
                self = .empty
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
            
        case let .success(.contracted(contractDetails)):
            switch contractDetails.paymentContract.contractStatus {
            case .active:
                self = contractDetails.bankDefaultResponse.requestLimitMessage == nil ? .active : .limit
                
            case .inactive:
                self = .inactive
            }
            
        case .success(.missingContract):
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

private extension FlowStubSettingsView.InitiateOTP {
    
    init?(flowStub: FlowStub?) {
        
        switch flowStub?.initiateOTP {
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

private extension FlowStubSettingsView.SubmitOTP {
    
    init?(flowStub: FlowStub?) {
        
        switch flowStub?.submitOTP {
        case .none:
            return nil
            
        case .success(()):
            self = .success
            
        case let .failure(failure):
            switch failure {
            case .connectivityError:
                self = .error_C
                
            case let .serverError(message):
                if message == "Введен некорректный код. Попробуйте еще раз" {
                    self = .incorrect
                } else {
                    self = .error_S
                }
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
        changeConsentList: .success,
        createContract:  .success(.active),
        getC2BSub: .success(.control),
        getSettings: .success(.contracted(.preview())),
        prepareSetBankDefault: .success(()),
        updateContract: .success(.inactive),
        updateProduct: .success(()),
        initiateOTP: .success(()),
        submitOTP: .success(())
    )
}
