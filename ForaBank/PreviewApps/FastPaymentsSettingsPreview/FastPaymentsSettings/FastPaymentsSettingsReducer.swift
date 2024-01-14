//
//  FastPaymentsSettingsReducer.swift
//  FastPaymentsSettingsPreview
//
//  Created by Igor Malyarov on 11.01.2024.
//

import Tagged

final class FastPaymentsSettingsReducer {
    
    private let getUserPaymentSettings: GetUserPaymentSettings
    private let updateContract: UpdateContract
    private let getProduct: GetProduct
    private let createContract: CreateContract
    private let prepareSetBankDefault: PrepareSetBankDefault
    
    init(
        getUserPaymentSettings: @escaping GetUserPaymentSettings,
        updateContract: @escaping UpdateContract,
        getProduct: @escaping GetProduct,
        createContract: @escaping CreateContract,
        prepareSetBankDefault: @escaping PrepareSetBankDefault
    ) {
        self.getUserPaymentSettings = getUserPaymentSettings
        self.updateContract = updateContract
        self.getProduct = getProduct
        self.createContract = createContract
        self.prepareSetBankDefault = prepareSetBankDefault
    }
}

extension FastPaymentsSettingsReducer {
    
    typealias Completion = (State) -> Void
    
    func reduce(
        _ state: State,
        _ event: Event,
        _ completion: @escaping Completion
    ) {
        switch event {
        case .appear:
            appear(state, completion)
            
        case .activateContract:
            activateContract(state, completion)
            
        case .deactivateContract:
            deactivateContract(state, completion)
            
        case .resetStatus:
            completion(state?.resetStatus())
            
        case .setBankDefault:
            setBankDefault(state, completion)
            
        case .prepareSetBankDefault:
            prepareSetBankDefault(state, completion)
            
        case .confirmSetBankDefault:
            confirmSetBankDefault(state, completion)
        }
    }
}

// micro-service `abc`
extension FastPaymentsSettingsReducer {
    
    typealias GetUserPaymentSettings = (@escaping (UserPaymentSettings) -> Void) -> Void
}

// micro-service `da`
extension FastPaymentsSettingsReducer {
    
    typealias UpdateContractPayload = (UserPaymentSettings.PaymentContract, UpdateContractToggle)
    typealias UpdateContractCompletion = (UpdateContractResponse) -> Void
    typealias UpdateContract = (UpdateContractPayload, @escaping UpdateContractCompletion) -> Void
    
    enum UpdateContractToggle {
        
        case activate, deactivate
    }
    
    enum UpdateContractResponse {
        
        case success(UserPaymentSettings.PaymentContract)
        case serverError(String)
        case connectivityError
    }
}

// micro-service `f`
extension FastPaymentsSettingsReducer {
    
    typealias PrepareSetBankDefaultCompletion = (PrepareSetBankDefaultResponse) -> Void
    typealias PrepareSetBankDefault = (@escaping PrepareSetBankDefaultCompletion) -> Void
    
    enum PrepareSetBankDefaultResponse {
        
        case success
        case serverError(String)
        case connectivityError
    }
}

extension FastPaymentsSettingsReducer {
    
    typealias GetProduct = () -> Product?
    
    struct Product: Identifiable {
        
        let id: ProductID
        
        typealias ProductID = Tagged<_ProductID, String>
        enum _ProductID {}
    }
}

// micro-service `ea`
extension FastPaymentsSettingsReducer {
    
    typealias CreateContractPayload = Product.ID
    typealias CreateContractCompletion = (CreateContractResponse) -> Void
    typealias CreateContract = (CreateContractPayload, @escaping CreateContractCompletion) -> Void
    
    enum CreateContractResponse {
        
        case success(UserPaymentSettings.PaymentContract)
        case serverError(String)
        case connectivityError
    }
}

extension FastPaymentsSettingsReducer {
    
    typealias State = FastPaymentsSettingsState?
    typealias Event = FastPaymentsSettingsEvent
}

private extension FastPaymentsSettingsReducer {
    
    func appear(
        _ state: State,
        _ completion: @escaping Completion
    ) {
        switch state {
        case .none:
            completion(.init(isInflight: true))
            
            getUserPaymentSettings {
                
                completion(.init(
                    userPaymentSettings: $0
                ))
            }
            
        default:
            completion(state)
        }
    }
    
    func activateContract(
        _ state: State,
        _ completion: @escaping Completion
    ) {
        switch state?.userPaymentSettings {
        case let .contracted(contractDetails):
            switch contractDetails.paymentContract.contractStatus {
            case .active:
                completion(state)
                
            case .inactive:
                completion(state?.setToInflight())
                activateContract(contractDetails, completion)
            }
            
        case let .missingContract(consent):
            completion(state?.setToInflight())
            
            if let product = getProduct() {
                createContract(product, consent, completion)
            } else {
                var state = state
                state?.status = .missingProduct
                completion(state)
            }
            
        default:
            completion(state)
        }
    }
    
    func activateContract(
        _ contractDetails: UserPaymentSettings.ContractDetails,
        _ completion: @escaping Completion
    ) {
        let payload = (contractDetails.paymentContract, UpdateContractToggle.activate)
        
        updateContract(payload) { result in
            
            let state: State
            
            switch result {
            case let .success(contract):
                var contractDetails = contractDetails
                contractDetails.paymentContract = contract
                state = .init(
                    userPaymentSettings: .contracted(contractDetails)
                )
                
            case let .serverError(message):
                state = .init(
                    userPaymentSettings: .contracted(contractDetails),
                    status: .serverError(message)
                )
                
            case .connectivityError:
                state = .init(
                    userPaymentSettings: .contracted(contractDetails),
                    status: .updateContractFailure
                )
            }
            
            completion(state)
        }
    }
    
    func deactivateContract(
        _ state: State,
        _ completion: @escaping Completion
    ) {
        switch state?.userPaymentSettings {
        case let .contracted(contractDetails):
            switch contractDetails.paymentContract.contractStatus {
            case .active:
                completion(state?.setToInflight())
                deactivateContract(contractDetails, completion)
                
            case .inactive:
                completion(state)
            }
            
        default:
            completion(state)
        }
    }
    
    func deactivateContract(
        _ contractDetails: UserPaymentSettings.ContractDetails,
        _ completion: @escaping Completion
    ) {
        let payload = (contractDetails.paymentContract, UpdateContractToggle.deactivate)
        
        updateContract(payload) { result in
            
            let state: State
            
            switch result {
            case let .success(contract):
                var contractDetails = contractDetails
                contractDetails.paymentContract = contract
                state = .init(
                    userPaymentSettings: .contracted(contractDetails)
                )
                
            case let .serverError(message):
                state = .init(
                    userPaymentSettings: .contracted(contractDetails),
                    status: .serverError(message)
                )
                
            case .connectivityError:
                state = .init(
                    userPaymentSettings: .contracted(contractDetails),
                    status: .updateContractFailure
                )
            }
            
            completion(state)
        }
    }
    
    func createContract(
        _ product: Product,
        _ consent: UserPaymentSettings.ConsentResult,
        _ completion: @escaping Completion
    ) {
        createContract(product.id) { result in
            
            let state: State
            
            switch result {
            case let .success(contract):
                state = .init(
                    userPaymentSettings: .contracted(.init(
                        paymentContract: contract,
                        consentResult: consent,
                        bankDefault: .offEnabled
                    ))
                )
                
            case let .serverError(message):
                state = .init(
                    userPaymentSettings: .missingContract(consent),
                    status: .serverError(message)
                )
                
            case .connectivityError:
                state = .init(
                    userPaymentSettings: .missingContract(consent),
                    status: .updateContractFailure
                )
            }
            
            completion(state)
        }
    }
    
    func setBankDefault(
        _ state: State,
        _ completion: @escaping Completion
    ) {
        var state = state
        state?.status = .setBankDefault
        completion(state)
    }
    
    func prepareSetBankDefault(
        _ state: State,
        _ completion: @escaping Completion
    ) {
        completion(state?.setToInflight())
        
        prepareSetBankDefault { result in
            
            var state = state
            
            switch result {
            case .success:
                state?.status = .confirmSetBankDefault
                
            case let .serverError(message):
                state?.status = .serverError(message)
                
            case .connectivityError:
                state?.status = .updateContractFailure
            }
            state?.isInflight = false
            
            completion(state)
        }
    }
    
    func confirmSetBankDefault(
        _ state: State,
        _ completion: @escaping Completion
    ) {
        switch state?.userPaymentSettings {
        case var .contracted(contractDetails):
            contractDetails.bankDefault = .onDisabled
            completion(.init(userPaymentSettings: .contracted(contractDetails)))
            
        default:
            completion(state)
        }
    }
}

private extension FastPaymentsSettingsState {
    
    init(isInflight: Bool) {
        
        self.init(status: .inflight)
    }
    
    func setToInflight() -> Self {
        
        var state = self
        state.isInflight = true
        
        return state
    }
    
    func resetStatus() -> Self {
        
        var state = self
        state.status = nil
        
        return state
    }
}
