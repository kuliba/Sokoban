//
//  PaymentsTransfersEffectHandler.swift
//  ForaBank
//
//  Created by Igor Malyarov on 27.02.2024.
//

import Foundation

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
        case let .getServicesFor(`operator`):
            getOperatorsListByParam(`operator`.id) {
            
                dispatch(.loaded($0, for: `operator`))
            }
            
        case let .startPayment(`operator`, utilityService):
            createAnywayTransfer((`operator`, utilityService)) {
                
                dispatch(.paymentStarted($0))
            }
        }
    }
}

extension PaymentsTransfersEffectHandler {
    
    typealias CreateAnywayTransferPayload = (UtilitiesViewModel.Operator, UtilityService)
    typealias CreateAnywayTransferCompletion = (Event.PaymentStarted) -> Void
    typealias CreateAnywayTransfer = (CreateAnywayTransferPayload, @escaping CreateAnywayTransferCompletion) -> Void
    
    typealias GetOperatorsListByParamPayload = String
    typealias GetOperatorsListByParamCompletion = (Event.GetOperatorsListByParamResponse) -> Void
    typealias GetOperatorsListByParam = (GetOperatorsListByParamPayload, @escaping GetOperatorsListByParamCompletion) -> Void
}

extension PaymentsTransfersEffectHandler {
    
    typealias Dispatch = (Event) -> Void
    
    typealias Event = PaymentsTransfersEvent
    typealias Effect = PaymentsTransfersEffect
}
