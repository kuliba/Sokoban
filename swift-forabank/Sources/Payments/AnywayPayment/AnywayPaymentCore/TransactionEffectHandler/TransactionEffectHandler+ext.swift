//
//  TransactionEffectHandler+ext.swift
//
//
//  Created by Igor Malyarov on 29.03.2024.
//

public extension TransactionEffectHandler {
    
    typealias Performer = TransactionPerformer<DocumentStatus, OperationDetails>
    
    convenience init(
        initiatePayment: @escaping MicroServices.InitiatePayment,
        getDetails: @escaping Performer.GetDetails,
        makeTransfer: @escaping Performer.MakeTransfer,
        paymentEffectHandle: @escaping MicroServices.PaymentEffectHandle,
        processPayment: @escaping MicroServices.ProcessPayment
    ) {
        let transactionPerformer = Performer(
            getDetails: getDetails,
            makeTransfer: makeTransfer
        )
        
        self.init(
            microServices: .init(
            initiatePayment: initiatePayment,
            makePayment: transactionPerformer.process,
            paymentEffectHandle: paymentEffectHandle,
            processPayment: processPayment
            )
        )
    }
}
