//
//  PaymentsTransfersFlowEffectHandlerMicroServices.swift
//  ForaBank
//
//  Created by Igor Malyarov on 04.07.2024.
//

struct PaymentsTransfersFlowEffectHandlerMicroServices {
    
    let initiatePayment: InitiatePayment
}

extension PaymentsTransfersFlowEffectHandlerMicroServices {
 
   typealias Payload = LatestPaymentData
   typealias InitiatePaymentResult = PaymentFlow.TransactionResult
   typealias InitiatePaymentCompletion = (InitiatePaymentResult) -> Void
   typealias InitiatePayment = (Payload, @escaping InitiatePaymentCompletion) -> Void
}
