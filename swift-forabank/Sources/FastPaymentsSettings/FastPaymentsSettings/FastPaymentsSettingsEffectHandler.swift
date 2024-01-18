//
//  FastPaymentsSettingsEffectHandler.swift
//
//
//  Created by Igor Malyarov on 15.01.2024.
//

import Tagged

public final class FastPaymentsSettingsEffectHandler {
    
    private let createContract: CreateContract
    private let getSettings: GetSettings
    private let prepareSetBankDefault: PrepareSetBankDefault
    private let updateContract: UpdateContract
    private let updateProduct: UpdateProduct
    
    public init(
        createContract: @escaping CreateContract,
        getSettings: @escaping GetSettings,
        prepareSetBankDefault: @escaping PrepareSetBankDefault,
        updateContract: @escaping UpdateContract,
        updateProduct: @escaping UpdateProduct
    ) {
        self.createContract = createContract
        self.getSettings = getSettings
        self.prepareSetBankDefault = prepareSetBankDefault
        self.updateContract = updateContract
        self.updateProduct = updateProduct
    }
}

public extension FastPaymentsSettingsEffectHandler {
    
    func handleEffect(
        _ effect: Effect,
        _ dispatch: @escaping Dispatch
    ) {
        switch effect {
        case let .activateContract(contract):
            activateContract(contract, dispatch)
            
        case let .createContract(productID):
            createContract(productID, dispatch)
            
        case let .deactivateContract(contract):
            deactivateContract(contract, dispatch)
            
        case .getSettings:
            getSettings(dispatch)
            
        case .prepareSetBankDefault:
            prepareSetBankDefault(dispatch)
            
        case let .updateProduct(payload):
            updateProduct(payload, dispatch)
        }
    }
}

// micro-service `ea`
public extension FastPaymentsSettingsEffectHandler {
    
    typealias CreateContractPayload = Effect.ProductID
#warning("`UpdateContractResponse` success case could only be `active` contract - need to find a way to enforce this")
    typealias CreateContractResponse = Result<UserPaymentSettings.PaymentContract, ServiceFailure>
    typealias CreateContractCompletion = (CreateContractResponse) -> Void
    typealias CreateContract = (CreateContractPayload, @escaping CreateContractCompletion) -> Void
}

// micro-service `abc`
public extension FastPaymentsSettingsEffectHandler {
    
    typealias GetSettings = (@escaping (UserPaymentSettings) -> Void) -> Void
}

// micro-service `f`
public extension FastPaymentsSettingsEffectHandler {
    
    typealias PrepareSetBankDefaultCompletion = (PrepareSetBankDefaultResponse) -> Void
    typealias PrepareSetBankDefaultResponse = Result<Void, ServiceFailure>
    typealias PrepareSetBankDefault = (@escaping PrepareSetBankDefaultCompletion) -> Void
}

// micro-service `da`
public extension FastPaymentsSettingsEffectHandler {
    
    typealias UpdateContractPayload = Effect.TargetContract
    #warning("`UpdateContractResponse` success case could only be `inactive` contract - need to find a way to enforce this")
    typealias UpdateContractResponse = Result<UserPaymentSettings.PaymentContract, ServiceFailure>
    typealias UpdateContractCompletion = (UpdateContractResponse) -> Void
    typealias UpdateContract = (UpdateContractPayload, @escaping UpdateContractCompletion) -> Void
}

// micro-service `d`
public extension FastPaymentsSettingsEffectHandler {
    
    typealias UpdateProductPayload = Effect.ContractCore
    typealias UpdateProductResponse = Result<Void, ServiceFailure>
    typealias UpdateProductCompletion = (UpdateProductResponse) -> Void
    typealias UpdateProduct = (UpdateProductPayload, @escaping UpdateProductCompletion) -> Void
}

public extension FastPaymentsSettingsEffectHandler {
    
    typealias Dispatch = (Event) -> Void
    
    enum ServiceFailure: Error, Equatable  {
        
        case connectivityError
        case serverError(String)
    }
    
    typealias State = FastPaymentsSettingsState
    typealias Event = FastPaymentsSettingsEvent
    typealias Effect = FastPaymentsSettingsEffect
}

private extension FastPaymentsSettingsEffectHandler {
    
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
    
    func getSettings(
        _ dispatch: @escaping Dispatch
    ) {
        getSettings { dispatch(.loadSettings($0)) }
    }
    
    func prepareSetBankDefault(
        _ dispatch: @escaping Dispatch
    ) {
        prepareSetBankDefault { result in
            
            switch result {
            case .success(()):
                dispatch(.setBankDefaultPrepared(nil))
                
            case .failure(.connectivityError):
                dispatch(.setBankDefaultPrepared(.connectivityError))
                
            case let .failure(.serverError(message)):
                dispatch(.setBankDefaultPrepared(.serverError(message)))
            }
        }
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
    
    func updateProduct(
        _ payload: UpdateProductPayload,
        _ dispatch: @escaping Dispatch
    ) {
        updateProduct(payload) { result in
            
            switch result {
            case .success(()):
                dispatch(.updateProduct(.success(payload.product)))
                
            case .failure(.connectivityError):
                dispatch(.updateProduct(.failure(.connectivityError)))
                
            case let .failure(.serverError(message)):
                dispatch(.updateProduct(.failure(.serverError(message))))
            }
        }
    }
}
