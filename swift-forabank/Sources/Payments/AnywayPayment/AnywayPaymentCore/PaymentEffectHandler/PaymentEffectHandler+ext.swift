//
//  PaymentEffectHandler+ext.swift
//
//
//  Created by Igor Malyarov on 29.03.2024.
//

public extension PaymentEffectHandler {
    
    typealias Performer = TransactionPerformer<DocumentStatus, OperationDetails>
    
    convenience init(
        getDetails: @escaping Performer.GetDetails,
        makeTransfer: @escaping Performer.MakeTransfer,
        parameterEffectHandle: @escaping ParameterEffectHandle,
        process: @escaping Process
    ) {
        let transactionPerformer = Performer(
            getDetails: getDetails,
            makeTransfer: makeTransfer
        )
        
        self.init(
            makePayment: transactionPerformer.process,
            parameterEffectHandle: parameterEffectHandle,
            process: process
        )
    }
}
