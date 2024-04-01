//
//  PaymentEffectHandler+ext.swift
//
//
//  Created by Igor Malyarov on 29.03.2024.
//

public extension PaymentEffectHandler {
    
    typealias Performer = TransactionPerformer<DocumentStatus, OperationDetails>
    
    convenience init(
        initiatePayment: @escaping InitiatePayment,
        getDetails: @escaping Performer.GetDetails,
        makeTransfer: @escaping Performer.MakeTransfer,
        parameterEffectHandle: @escaping ParameterEffectHandle,
        processPayment: @escaping ProcessPayment
    ) {
        let transactionPerformer = Performer(
            getDetails: getDetails,
            makeTransfer: makeTransfer
        )
        
        self.init(
            initiatePayment: initiatePayment,
            makePayment: transactionPerformer.process,
            parameterEffectHandle: parameterEffectHandle,
            processPayment: processPayment
        )
    }
}
