//
//  FastPaymentsSettingsReducer.swift
//  FastPaymentsSettingsPreview
//
//  Created by Igor Malyarov on 11.01.2024.
//

final class FastPaymentsSettingsReducer {
    
    private let getUserPaymentSettings: GetUserPaymentSettings
    private let updateContract: UpdateContract
    private let getProduct: GetProduct
    private let createContract: CreateContract
    
    init(
        getUserPaymentSettings: @escaping GetUserPaymentSettings,
        updateContract: @escaping UpdateContract,
        getProduct: @escaping GetProduct,
        createContract: @escaping CreateContract
    ) {
        self.getUserPaymentSettings = getUserPaymentSettings
        self.updateContract = updateContract
        self.getProduct = getProduct
        self.createContract = createContract
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
            handleAppear(state, completion)
            
        case .activateContract:
            activateContract(state, completion)
            
        case .deactivateContract:
            deactivateContract(state, completion)
            
        case .resetError:
            completion(state?.noError())
            
        case .setBankDefault:
            setBankDefault(state, completion)
        }
    }
    
    private func handleAppear(
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
    
    private func activateContract(
        _ state: State,
        _ completion: @escaping Completion
    ) {
        switch state?.userPaymentSettings {
        case let .contracted(contractDetails):
            switch contractDetails.paymentContract.contractStatus {
            case .active:
                completion(state)
                
            case .inactive:
                completion(state?.toInflight())
                activateContract(contractDetails, completion)
            }
            
        case let .missingContract(consent):
            completion(state?.toInflight())
            
            if let product = getProduct() {
                createContract(product, consent, completion)
            } else {
                var state = state
                state?.alert = .missingProduct
                completion(state)
            }
            
        default:
            completion(state)
        }
    }
    
    private func activateContract(
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
                    alert: .serverError(message)
                )
                
            case .connectivityError:
                state = .init(
                    userPaymentSettings: .contracted(contractDetails),
                    alert: .updateContractFailure
                )
            }
            
            completion(state)
        }
    }
    
    private func deactivateContract(
        _ state: State,
        _ completion: @escaping Completion
    ) {
        switch state?.userPaymentSettings {
        case let .contracted(contractDetails):
            switch contractDetails.paymentContract.contractStatus {
            case .active:
                completion(state?.toInflight())
                deactivateContract(contractDetails, completion)
                
            case .inactive:
                completion(state)
            }
            
        default:
            completion(state)
        }
    }
    
    private func deactivateContract(
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
                    alert: .serverError(message)
                )
                
            case .connectivityError:
                state = .init(
                    userPaymentSettings: .contracted(contractDetails),
                    alert: .updateContractFailure
                )
            }
            
            completion(state)
        }
    }
    
    private func createContract(
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
                    alert: .serverError(message)
                )
                
            case .connectivityError:
                state = .init(
                    userPaymentSettings: .missingContract(consent),
                    alert: .updateContractFailure
                )
            }
            
            completion(state)
        }
    }
    
    private func setBankDefault(
        _ state: State,
        _ completion: @escaping Completion
    ) {
        var state = state
        state?.alert = .confirmSetBankDefault
        completion(state)
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

extension FastPaymentsSettingsReducer {
    
    typealias GetProduct = () -> Product?
    
    struct Product: Identifiable {
        
        let id: ProductID
        
#warning("replace with Tagged")
        typealias ProductID = String
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
    
    typealias State = FastPaymentsSettingsViewModel.State?
    typealias Event = FastPaymentsSettingsViewModel.Event
}

extension FastPaymentsSettingsViewModel.State {
    
    func toInflight() -> Self {
        
        var state = self
        state.isInflight = true
        
        return state
    }
    
    func noError() -> Self {
        
        var state = self
        state.alert = nil
        
        return state
    }
}
