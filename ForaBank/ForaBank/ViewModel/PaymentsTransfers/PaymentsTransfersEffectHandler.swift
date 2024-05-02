//
//  PaymentsTransfersEffectHandler.swift
//  ForaBank
//
//  Created by Igor Malyarov on 27.02.2024.
//

import Foundation
import OperatorsListComponents

final class PaymentsTransfersEffectHandler {
    
    private let createAnywayTransfer: CreateAnywayTransfer
    private let getOperatorsListByParam: GetOperatorsListByParam
    
    init(
        createAnywayTransfer: @escaping CreateAnywayTransfer,
        getOperatorsListByParam: @escaping GetOperatorsListByParam
    ) {
        self.createAnywayTransfer = createAnywayTransfer
        self.getOperatorsListByParam = getOperatorsListByParam
    }
}

extension PaymentsTransfersEffectHandler {
    
    func handleEffect(
        _ effect: Effect,
        _ dispatch: @escaping Dispatch
    ) {
        switch effect {
        case let .utilityFlow(utilityFlowEffect):
            handleEffect(utilityFlowEffect, { dispatch(.utilityFlow($0)) })
        }
    }
}

extension PaymentsTransfersEffectHandler {
    
    typealias LatestPayment = OperatorsListComponents.LatestPayment
    typealias Operator = OperatorsListComponents.Operator
    
    typealias CreateAnywayTransferPayload = PaymentsTransfersEffect.UtilityServicePaymentFlowEffect.StartPaymentPayload
    typealias CreateAnywayTransferCompletion = (Event.PaymentStarted) -> Void
    typealias CreateAnywayTransfer = (CreateAnywayTransferPayload<LatestPayment, Operator>, @escaping CreateAnywayTransferCompletion) -> Void
    
    typealias GetOperatorsListByParamPayload = String
    typealias GetOperatorsListByParamCompletion = (Event.GetOperatorsListByParamResponse) -> Void
    typealias GetOperatorsListByParam = (GetOperatorsListByParamPayload, @escaping GetOperatorsListByParamCompletion) -> Void
}

extension PaymentsTransfersEffectHandler {
    
    typealias UtilityFlowEvent = Event.UtilityServicePaymentFlowEvent
    typealias UtilityFlowDispatch = (UtilityFlowEvent) -> Void
    
    typealias Dispatch = (Event) -> Void
    
    typealias Event = PaymentsTransfersEvent
    typealias Effect = PaymentsTransfersEffect
}

private extension PaymentsTransfersEffectHandler {
    
    #warning("extractable")
    func handleEffect(
        _ effect: Effect.UtilityServicePaymentFlowEffect,
        _ dispatch: @escaping UtilityFlowDispatch
    ) {
        switch effect {
        case let .getServicesFor(`operator`):
            getOperatorsListByParam(`operator`.id) {
            
                dispatch(.loaded($0, for: `operator`))
            }
            
        case let .startPayment(payload):
            createAnywayTransfer(payload) {
                
                dispatch(.paymentStarted($0))
            }
        }
    }
}
