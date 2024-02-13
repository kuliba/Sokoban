//
//  FastPaymentsSettingsEffectHandler.swift
//
//
//  Created by Igor Malyarov on 15.01.2024.
//

import C2BSubscriptionUI
import Tagged

public final class FastPaymentsSettingsEffectHandler {
    
    private let handleConsentListEffect: HandleConsentListEffect
    private let handleContractEffect: HandleContractEffect
    private let getC2BSub: GetC2BSub
    private let getSettings: GetSettings
    private let prepareSetBankDefault: PrepareSetBankDefault
    private let updateProduct: UpdateProduct
    
    public init(
        handleConsentListEffect: @escaping HandleConsentListEffect,
        handleContractEffect: @escaping HandleContractEffect,
        getC2BSub: @escaping GetC2BSub,
        getSettings: @escaping GetSettings,
        prepareSetBankDefault: @escaping PrepareSetBankDefault,
        updateProduct: @escaping UpdateProduct
    ) {
        self.handleConsentListEffect = handleConsentListEffect
        self.handleContractEffect = handleContractEffect
        self.getC2BSub = getC2BSub
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
            handleContractEffect(contract) { dispatch(.contract($0)) }
            
        case .getSettings:
            getSettings(dispatch)
            
        case .prepareSetBankDefault:
            prepareSetBankDefault(dispatch)
            
#warning("add tests")
        case let .subscription(subscription):
            switch subscription {
            case .getC2BSub:
                getC2BSub(dispatch)
            }
            
        case let .updateProduct(payload):
            updateProduct(payload, dispatch)
        }
    }
}

// micro-service `abc`
public extension FastPaymentsSettingsEffectHandler {
    
    typealias ConsentListDispatch = (ConsentListEvent) -> Void
    typealias HandleConsentListEffect = (ConsentListEffect, @escaping ConsentListDispatch) -> Void
    typealias HandleContractEffect = (ContractEffect, @escaping ContractDispatch) -> Void
    typealias GetC2BSub = (@escaping (GetC2BSubResult) -> Void) -> Void
    typealias GetSettings = (@escaping (UserPaymentSettingsResult) -> Void) -> Void
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
    
    typealias GetC2BSubResult = Result<GetC2BSubResponse, ServiceFailure>
}

public extension FastPaymentsSettingsEffectHandler {
    
    typealias Dispatch = (Event) -> Void
    typealias ContractDispatch = (ContractEvent) -> Void
    
    typealias State = FastPaymentsSettingsState
    typealias Event = FastPaymentsSettingsEvent
    typealias Effect = FastPaymentsSettingsEffect
}

private extension FastPaymentsSettingsEffectHandler {
    
#warning("add tests")
    func getC2BSub(
        _ dispatch: @escaping Dispatch
    ) {
        getC2BSub { dispatch(.subscription(.loaded($0.getC2BSubResultEvent))) }
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
                dispatch(.bankDefault(.setBankDefaultResult(.success)))
                
            case let .failure(failure):
                switch failure {
                case .connectivityError:
                    dispatch(.bankDefault(.setBankDefaultResult(.serviceFailure(.connectivityError))))
                    
                case let .serverError(message):
                    let tryAgain = "Введен некорректный код. Попробуйте еще раз"
                    
                    if message == tryAgain {
                        dispatch(.bankDefault(.setBankDefaultResult(.incorrectOTP(tryAgain))))
                    } else {
                        dispatch(.bankDefault(.setBankDefaultResult(.serviceFailure(.serverError(message)))))
                    }
                }
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
                dispatch(.products(.updateProduct(.success(payload.selectableProductID))))
                
            case .failure(.connectivityError):
                dispatch(.products(.updateProduct(.failure(.connectivityError))))
                
            case let .failure(.serverError(message)):
                dispatch(.products(.updateProduct(.failure(.serverError(message)))))
            }
        }
    }
}

private extension FastPaymentsSettingsEffectHandler.GetC2BSubResult {
    
    var getC2BSubResultEvent: GetC2BSubResult {
        
        switch self {
        case let .success(success):
            return .success(success)
            
        case let .failure(failure):
            switch failure {
            case .connectivityError:
                return .failure(.connectivityError)
                
            case let .serverError(message):
                return .failure(.serverError(message))
            }
        }
    }
}
