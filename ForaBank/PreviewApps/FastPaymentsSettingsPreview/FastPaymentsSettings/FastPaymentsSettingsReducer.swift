//
//  FastPaymentsSettingsReducer.swift
//  FastPaymentsSettingsPreview
//
//  Created by Igor Malyarov on 11.01.2024.
//

final class FastPaymentsSettingsReducer {
    
    private let getContractConsentAndDefault: GetContractConsentAndDefault
    private let updateContract: UpdateContract
    
    init(
        getContractConsentAndDefault: @escaping GetContractConsentAndDefault,
        updateContract: @escaping UpdateContract
    ) {
        self.getContractConsentAndDefault = getContractConsentAndDefault
        self.updateContract = updateContract
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
            
        case let .missingContract(consentResult):
#warning("TBD")
            break
            
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
                    error: .updateFailure
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
                    error: .updateFailure
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
