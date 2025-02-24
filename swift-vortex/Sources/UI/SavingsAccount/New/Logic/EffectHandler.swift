//
//  EffectHandler.swift
//
//
//  Created by Andryusina Nataly on 20.02.2025.
//

import Foundation
import LoadableState

public final class EffectHandler<Confirmation> {
    
    private let load: Load
    private let loadConfirmation: LoadConfirmation
    private let orderAccount: OrderAccount
    
    public init(
        load: @escaping Load,
        loadConfirmation: @escaping LoadConfirmation,
        orderAccount: @escaping OrderAccount
    ) {
        self.load = load
        self.loadConfirmation = loadConfirmation
        self.orderAccount = orderAccount
    }
    
    public typealias DismissInformer = () -> Void
    public typealias Load = (@escaping DismissInformer, @escaping (LoadFormResult<Confirmation>) -> Void) -> Void
    
    public enum ConfirmationEvent {
        
        case dismissInformer
        case otp(String)
    }
}

public extension EffectHandler {
    
    func handleEffect(
        _ effect: Effect,
        _ dispatch: @escaping Dispatch
    ) {
        switch effect {
        case .load:
            load({ dispatch(.dismissInformer) }) { dispatch(.loaded($0)) }
            
        case let .loadConfirmation(payload):
            
            let confirmationNotify: ConfirmationNotify = {
                
                switch $0 {
                case .dismissInformer:
                    dispatch(.dismissInformer)
                    
                case let .otp(otp):
                    dispatch(.otp(otp))
                }
            }
            loadConfirmation(payload, confirmationNotify) { dispatch(.loadConfirmation($0)) }
            
        case let .orderAccount(payload):
            orderAccount(payload) { dispatch(.orderAccountResult($0)) }
        }
    }
}

public extension EffectHandler {
    
    typealias Dispatch = (ProductEvent<Confirmation>) -> Void
    typealias Effect = ProductEffect

    typealias ConfirmationNotify = (ConfirmationEvent) -> Void
    typealias LoadConfirmation = (ProductEffect.LoadConfirmationPayload, @escaping ConfirmationNotify, @escaping (LoadConfirmationResult<Confirmation>) -> Void) -> Void
    
    typealias OrderAccount = (ProductEffect.OrderAccountPayload, @escaping (ProductEvent.OrderAccountResult) -> Void) -> Void
}
