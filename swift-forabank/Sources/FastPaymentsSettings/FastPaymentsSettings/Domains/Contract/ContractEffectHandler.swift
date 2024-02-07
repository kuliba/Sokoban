//
//  ContractEffectHandler.swift
//
//
//  Created by Igor Malyarov on 20.01.2024.
//

#warning("add tests")
public final class ContractEffectHandler {
    
    private let createContract: CreateContract
    private let updateContract: UpdateContract
    
    public init(
        createContract: @escaping CreateContract,
        updateContract: @escaping UpdateContract
    ) {
        self.createContract = createContract
        self.updateContract = updateContract
    }
}

public extension ContractEffectHandler {
    
    func handleEffect(
        _ effect: Effect,
        _ dispatch: @escaping Dispatch
    ) {
        switch effect {
        case let .activateContract(contract):
            activateContract(contract, dispatch)
            
        case let .createContract(product):
            createContract(product, dispatch)
            
        case let .deactivateContract(contract):
            deactivateContract(contract, dispatch)
        }
    }
}

// micro-service `ea`
public extension ContractEffectHandler {
    
    typealias CreateContractPayload = Product
#warning("`UpdateContractResponse` success case could only be `active` contract - need to find a way to enforce this")
    typealias CreateContractResult = Result<UserPaymentSettings.PaymentContract, ServiceFailure>
    typealias CreateContractCompletion = (CreateContractResult) -> Void
    typealias CreateContract = (CreateContractPayload, @escaping CreateContractCompletion) -> Void
}

// micro-service `da`
public extension ContractEffectHandler {
    
    typealias UpdateContractPayload = ContractEffect.TargetContract
#warning("`UpdateContractResponse` success case could only be `inactive` contract - need to find a way to enforce this")
    typealias UpdateContractResult = Result<UserPaymentSettings.PaymentContract, ServiceFailure>
    typealias UpdateContractCompletion = (UpdateContractResult) -> Void
    typealias UpdateContract = (UpdateContractPayload, @escaping UpdateContractCompletion) -> Void
}

public extension ContractEffectHandler {
    
    typealias Dispatch = (Event) -> Void
    
    typealias Event = ContractEvent
    typealias Effect = ContractEffect
}

private extension ContractEffectHandler {
    
    func activateContract(
        _ payload: UpdateContractPayload,
        _ dispatch: @escaping Dispatch
    ) {
        updateContract(payload, dispatch)
    }
    
    func createContract(
        _ productID: CreateContractPayload,
        _ dispatch: @escaping Dispatch
    ) {
        createContract(productID) { result in
            
            switch result {
            case let .success(contract):
                dispatch(.updateContract(.success(contract)))
                
            case .failure(.connectivityError):
                dispatch(.updateContract(.failure(.connectivityError)))
                
            case let .failure(.serverError(message)):
                dispatch(.updateContract(.failure(.serverError(message))))
            }
        }
    }
    
    func deactivateContract(
        _ payload: UpdateContractPayload,
        _ dispatch: @escaping Dispatch
    ) {
        updateContract(payload, dispatch)
    }
    
    func updateContract(
        _ payload: UpdateContractPayload,
        _ dispatch: @escaping Dispatch
    ) {
        updateContract(payload) { result in
            
            switch result {
            case let .success(contract):
                dispatch(.updateContract(.success(contract)))
                
            case .failure(.connectivityError):
                dispatch(.updateContract(.failure(.connectivityError)))
                
            case let .failure(.serverError(message)):
                dispatch(.updateContract(.failure(.serverError(message))))
            }
        }
    }
}
