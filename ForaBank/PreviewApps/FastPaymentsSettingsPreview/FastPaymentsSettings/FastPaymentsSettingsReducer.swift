//
//  FastPaymentsSettingsReducer.swift
//  FastPaymentsSettingsPreview
//
//  Created by Igor Malyarov on 11.01.2024.
//

final class FastPaymentsSettingsReducer {
    
    private let getContractConsentAndDefault: GetContractConsentAndDefault
    private let updateContract: UpdateContract
    private let getProduct: GetProduct
    private let createContract: CreateContract
    
    init(
        getContractConsentAndDefault: @escaping GetContractConsentAndDefault,
        updateContract: @escaping UpdateContract,
        getProduct: @escaping GetProduct,
        createContract: @escaping CreateContract
    ) {
        self.getContractConsentAndDefault = getContractConsentAndDefault
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
        }
    }
    
    private func handleAppear(
        _ state: State,
        _ completion: @escaping Completion
    ) {
        switch state {
        case .none:
            completion(.init(inflight: true))
            
            getContractConsentAndDefault {
                
                completion(.init(
                    contractConsentAndDefault: $0
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
        switch state?.contractConsentAndDefault {
        case let .contracted(contractDetails, status):
            switch status {
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
                state?.error = .missingProduct
                completion(state)
            }
            
        default:
            completion(state)
        }
    }
    
    private func activateContract(
        _ contractDetails: ContractConsentAndDefault.ContractDetails,
        _ completion: @escaping Completion
    ) {
        let payload = (contractDetails.contract, UpdateContractToggle.activate)
        
        updateContract(payload) { result in
            
            let state: State
            
            switch result {
            case let .success(contract):
                var contractDetails = contractDetails
                contractDetails.contract = contract
                state = .init(
                    contractConsentAndDefault: .contracted(contractDetails, .active)
                )
                
            case let .serverError(message):
                state = .init(
                    contractConsentAndDefault: .contracted(contractDetails, .inactive),
                    error: .serverError(message)
                )
                
            case .connectivityError:
                state = .init(
                    contractConsentAndDefault: .contracted(contractDetails, .inactive),
                    error: .updateContractFailure
                )
            }
            
            completion(state)
        }
    }
    
    private func deactivateContract(
        _ state: State,
        _ completion: @escaping Completion
    ) {
        switch state?.contractConsentAndDefault {
        case let .contracted(contractDetails, status):
            switch status {
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
        _ contractDetails: ContractConsentAndDefault.ContractDetails,
        _ completion: @escaping Completion
    ) {
        let payload = (contractDetails.contract, UpdateContractToggle.deactivate)
        
        updateContract(payload) { result in
            
            let state: State
            
            switch result {
            case let .success(contract):
                var contractDetails = contractDetails
                contractDetails.contract = contract
                state = .init(
                    contractConsentAndDefault: .contracted(contractDetails, .inactive)
                )
                
            case let .serverError(message):
                state = .init(
                    contractConsentAndDefault: .contracted(contractDetails, .active),
                    error: .serverError(message)
                )
                
            case .connectivityError:
                state = .init(
                    contractConsentAndDefault: .contracted(contractDetails, .active),
                    error: .updateContractFailure
                )
            }

            completion(state)
        }
    }
    
    private func createContract(
        _ product: Product,
        _ consent: ContractConsentAndDefault.ConsentResult,
        _ completion: @escaping Completion
    ) {
        createContract(product.id) { result in
            
            let state: State
            
            switch result {
            case let .success(contract):
                state = .init(
                    contractConsentAndDefault: .contracted(
                        .init(
                            contract: contract,
                            consentResult: consent,
                            bankDefault: .offEnabled
                        ),
                        .active
                    )
                )
                
            case let .serverError(message):
                state = .init(
                    contractConsentAndDefault: .missingContract(consent),
                    error: .serverError(message)
                )
                
            case .connectivityError:
                state = .init(
                    contractConsentAndDefault: .missingContract(consent),
                    error: .updateContractFailure
                )
            }
            
            completion(state)
        }
    }
}

// micro-service `abc`
extension FastPaymentsSettingsReducer {
    
    typealias GetContractConsentAndDefault = (@escaping (ContractConsentAndDefault) -> Void) -> Void
}

// micro-service `da`
extension FastPaymentsSettingsReducer {
    
    typealias UpdateContractPayload = (ContractConsentAndDefault.Contract, UpdateContractToggle)
    typealias UpdateContractCompletion = (UpdateContractResponse) -> Void
    typealias UpdateContract = (UpdateContractPayload, @escaping UpdateContractCompletion) -> Void
    
    enum UpdateContractToggle {
        
        case activate, deactivate
    }
    
    enum UpdateContractResponse {
        
        case success(ContractConsentAndDefault.Contract)
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
        
        case success(ContractConsentAndDefault.Contract)
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
        state.inflight = true
        
        return state
    }
    
    func noError() -> Self {
        
        var state = self
        state.error = nil
        
        return state
    }
}
