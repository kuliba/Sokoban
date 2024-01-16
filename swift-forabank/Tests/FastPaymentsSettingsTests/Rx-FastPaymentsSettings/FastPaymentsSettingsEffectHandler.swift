//
//  FastPaymentsSettingsEffectHandler.swift
//
//
//  Created by Igor Malyarov on 15.01.2024.
//

import FastPaymentsSettings

final class FastPaymentsSettingsEffectHandler {
    
    private let getUserPaymentSettings: GetUserPaymentSettings
    private let updateContract: UpdateContract
    
    init(
        getUserPaymentSettings: @escaping GetUserPaymentSettings,
        updateContract: @escaping UpdateContract
    ) {
        self.getUserPaymentSettings = getUserPaymentSettings
        self.updateContract = updateContract
    }
}

extension FastPaymentsSettingsEffectHandler {
    
    func handleEffect(
        _ effect: Effect,
        _ dispatch: @escaping Dispatch
    ) {
        switch effect {
        case .getUserPaymentSettings:
            getUserPaymentSettings(dispatch)
            
        case let .activateContract(contract):
            activateContract(contract, dispatch)
        }
    }
}

// micro-service `abc`
extension FastPaymentsSettingsEffectHandler {
    
    typealias GetUserPaymentSettings = (@escaping (UserPaymentSettings) -> Void) -> Void
}

// micro-service `da`
extension FastPaymentsSettingsEffectHandler {
    
    typealias UpdateContractPayload = (UserPaymentSettings.PaymentContract, UpdateContractToggle)
    typealias UpdateContractCompletion = (UpdateContractResponse) -> Void
    typealias UpdateContract = (UpdateContractPayload, @escaping UpdateContractCompletion) -> Void
    
    enum UpdateContractToggle: Equatable {
        
        case activate, deactivate
    }
    
    enum UpdateContractResponse {
        
        case success(UserPaymentSettings.PaymentContract)
        case serverError(String)
        case connectivityError
    }
}

extension FastPaymentsSettingsEffectHandler {
    
    typealias Dispatch = (Event) -> Void
    
    typealias State = FastPaymentsSettingsState
    typealias Event = FastPaymentsSettingsEvent
    typealias Effect = FastPaymentsSettingsEffect
}

private extension FastPaymentsSettingsEffectHandler {
    
    func getUserPaymentSettings(
        _ dispatch: @escaping Dispatch
    ) {
        getUserPaymentSettings {
            
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
                dispatch(.updatedSuccess(contract))
                
            case let .serverError(message):
                fatalError("unimplemented")

            case .connectivityError:
                fatalError("unimplemented")
            }
        }
    }
}
