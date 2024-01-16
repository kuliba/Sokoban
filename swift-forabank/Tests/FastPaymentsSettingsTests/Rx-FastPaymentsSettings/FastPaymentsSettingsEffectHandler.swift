//
//  FastPaymentsSettingsEffectHandler.swift
//
//
//  Created by Igor Malyarov on 15.01.2024.
//

import FastPaymentsSettings
import Tagged

final class FastPaymentsSettingsEffectHandler {
    
    private let createContract: CreateContract
    private let getSettings: GetSettings
    private let prepareSetBankDefault: PrepareSetBankDefault
    private let updateContract: UpdateContract
    private let updateProduct: UpdateProduct
    
    init(
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

extension FastPaymentsSettingsEffectHandler {
    
    func handleEffect(
        _ effect: Effect,
        _ dispatch: @escaping Dispatch
    ) {
        switch effect {
        case let .activateContract(contract):
            activateContract(contract, dispatch)
            
        case let .createContract(productID):
            createContract(productID, dispatch)
            
        case .getUserPaymentSettings:
            getUserPaymentSettings(dispatch)
            
        case .prepareSetBankDefault:
            prepareSetBankDefault(dispatch)
        }
    }
}

// micro-service `ea`
extension FastPaymentsSettingsEffectHandler {
    
    typealias CreateContractPayload = Product.ID
    typealias CreateContractResponse = Result<UserPaymentSettings.PaymentContract, ServiceFailure>
    typealias CreateContractCompletion = (CreateContractResponse) -> Void
    typealias CreateContract = (CreateContractPayload, @escaping CreateContractCompletion) -> Void
}

// micro-service `abc`
extension FastPaymentsSettingsEffectHandler {
    
    typealias GetSettings = (@escaping (UserPaymentSettings) -> Void) -> Void
}

// micro-service `f`
extension FastPaymentsSettingsEffectHandler {
    
    typealias PrepareSetBankDefaultCompletion = (PrepareSetBankDefaultResponse) -> Void
    typealias PrepareSetBankDefaultResponse = Result<Void, ServiceFailure>
    typealias PrepareSetBankDefault = (@escaping PrepareSetBankDefaultCompletion) -> Void
}

// micro-service `da`
extension FastPaymentsSettingsEffectHandler {
    
    typealias UpdateContractPayload = (UserPaymentSettings.PaymentContract, UpdateContractToggle)
    typealias UpdateContractResponse = Result<UserPaymentSettings.PaymentContract, ServiceFailure>
    typealias UpdateContractCompletion = (UpdateContractResponse) -> Void
    typealias UpdateContract = (UpdateContractPayload, @escaping UpdateContractCompletion) -> Void
    
    enum UpdateContractToggle: Equatable {
        
        case activate, deactivate
    }
}

// micro-service `d`
extension FastPaymentsSettingsEffectHandler {
    
    typealias UpdateProductResponse = Result<Void, ServiceFailure>
    typealias UpdateProductCompletion = (UpdateProductResponse) -> Void
    typealias UpdateProduct = (UpdateProductPayload, @escaping UpdateProductCompletion) -> Void
    
    struct UpdateProductPayload {
        
        let contractID: ContractID
        let productID: ProductID
        let productType: ProductType
        
        typealias ContractID = Tagged<_ContractID, Int>
        enum _ContractID {}
        
        typealias ProductID = Tagged<_ProductID, Int>
        enum _ProductID {}
        
        enum ProductType {
            
            case account, card
        }
    }
}

extension FastPaymentsSettingsEffectHandler {
    
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
    
    func getUserPaymentSettings(
        _ dispatch: @escaping Dispatch
    ) {
        getSettings {
            
            dispatch(.loadedUserPaymentSettings($0))
        }
    }
    
    func activateContract(
        _ contract: UserPaymentSettings.PaymentContract,
        _ dispatch: @escaping Dispatch
    ) {
        updateContract((contract, .activate)) { result in
            
            switch result {
            case let .success(contract):
                dispatch(.contractUpdate(.success(contract)))
                
            case .failure(.connectivityError):
                dispatch(.contractUpdate(.failure(.connectivityError)))
                
            case let .failure(.serverError(message)):
                dispatch(.contractUpdate(.failure(.serverError(message))))
            }
        }
    }
    
    func prepareSetBankDefault(
        _ dispatch: @escaping Dispatch
    ) {
        prepareSetBankDefault { result in
            
            switch result {
            case .success(()):
                dispatch(.setBankDefaultPrepare(nil))
                
            case .failure(.connectivityError):
                dispatch(.setBankDefaultPrepare(.connectivityError))
                
            case let .failure(.serverError(message)):
                dispatch(.setBankDefaultPrepare(.serverError(message)))
            }
        }
    }
    
    func createContract(
        _ productID: Product.ID,
        _ dispatch: @escaping Dispatch
    ) {
        createContract(productID) { result in
            
            switch result {
            case let .success(contract):
                dispatch(.contractUpdate(.success(contract)))
                
            case .failure(.connectivityError):
                dispatch(.contractUpdate(.failure(.connectivityError)))
                
            case let .failure(.serverError(message)):
                dispatch(.contractUpdate(.failure(.serverError(message))))
            }
        }
    }
}
