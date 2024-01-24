//
//  FastPaymentsSettingsEffectHandler.swift
//
//
//  Created by Igor Malyarov on 15.01.2024.
//

import Tagged

public final class FastPaymentsSettingsEffectHandler {
    
    private let handleConsentListEffect: HandleConsentListEffect
    private let handleContractEffect: HandleContractEffect
    private let getSettings: GetSettings
    private let prepareSetBankDefault: PrepareSetBankDefault
    private let updateProduct: UpdateProduct
    
    public init(
        handleConsentListEffect: @escaping HandleConsentListEffect,
        handleContractEffect: @escaping HandleContractEffect,
        getSettings: @escaping GetSettings,
        prepareSetBankDefault: @escaping PrepareSetBankDefault,
        updateProduct: @escaping UpdateProduct
    ) {
        self.handleConsentListEffect = handleConsentListEffect
        self.handleContractEffect = handleContractEffect
        self.getSettings = getSettings
        self.prepareSetBankDefault = prepareSetBankDefault
        self.updateProduct = updateProduct
    }
}

public extension FastPaymentsSettingsEffectHandler {
    
    func handleEffect(
        _ effect: Effect,
        _ dispatch: @escaping Dispatch
    ) {
        switch effect {
#warning("add tests")
        case let .consentList(consentList):
            handleConsentListEffect(consentList) { dispatch(.consentList($0)) }
            
        case let .contract(contract):
            handleContractEffect(contract, dispatch)
            
        case .getSettings:
            getSettings(dispatch)
            
        case .prepareSetBankDefault:
            prepareSetBankDefault(dispatch)
            
        case let .updateProduct(payload):
            updateProduct(payload, dispatch)
        }
    }
}

// micro-service `abc`
public extension FastPaymentsSettingsEffectHandler {
    
    typealias ConsentListDispatch = (ConsentListEvent) -> Void
    typealias HandleConsentListEffect = (ConsentListEffect, @escaping ConsentListDispatch) -> Void
    typealias HandleContractEffect = (Effect.Contract, @escaping Dispatch) -> Void
    typealias GetSettings = (@escaping (UserPaymentSettings) -> Void) -> Void
}

// micro-service `f`
public extension FastPaymentsSettingsEffectHandler {
    
    typealias PrepareSetBankDefaultResponse = Result<Void, ServiceFailure>
    typealias PrepareSetBankDefaultCompletion = (PrepareSetBankDefaultResponse) -> Void
    typealias PrepareSetBankDefault = (@escaping PrepareSetBankDefaultCompletion) -> Void
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
                dispatch(.bankDefault(.setBankDefaultPrepared(nil)))
                
            case .failure(.connectivityError):
                dispatch(.bankDefault(.setBankDefaultPrepared(.connectivityError)))
                
            case let .failure(.serverError(message)):
                dispatch(.bankDefault(.setBankDefaultPrepared(.serverError(message))))
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
                dispatch(.products(.updateProduct(.success(payload.product))))
                
            case .failure(.connectivityError):
                dispatch(.products(.updateProduct(.failure(.connectivityError))))
                
            case let .failure(.serverError(message)):
                dispatch(.products(.updateProduct(.failure(.serverError(message)))))
            }
        }
    }
}
