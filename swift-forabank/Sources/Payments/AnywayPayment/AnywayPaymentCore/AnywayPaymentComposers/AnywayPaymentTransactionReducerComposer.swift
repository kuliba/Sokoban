//
//  AnywayPaymentTransactionReducerComposer.swift
//
//
//  Created by Igor Malyarov on 27.05.2024.
//

import AnywayPaymentDomain

public final class AnywayPaymentTransactionReducerComposer<Report> {
    
    public init() {}
}

public extension AnywayPaymentTransactionReducerComposer {
    
    func compose() -> Reducer {
        
        return .init(
            paymentReduce: paymentReduce(),
            stagePayment: stagePayment,
            updatePayment: updatePayment,
            paymentInspector: composeInspector()
        )
    }
}

public extension AnywayPaymentTransactionReducerComposer {
    
    typealias Reducer = TransactionReducer<Report, AnywayPaymentContext, AnywayPaymentEvent, AnywayPaymentEffect, AnywayPaymentDigest, AnywayPaymentUpdate>
}

extension AnywayPaymentContext: RestartablePayment {}

private extension AnywayPaymentTransactionReducerComposer {
    
    func paymentReduce() -> Reducer.PaymentReduce {
        
        let paymentReducer = AnywayPaymentReducer()
        let reducer = AnywayPaymentContextReducer(
            anywayPaymentReduce: paymentReducer.reduce(_:_:)
        )
        
        return reducer.reduce(_:_:)
    }
    
    func stagePayment(
        _ context: AnywayPaymentContext
    ) -> AnywayPaymentContext {
        
        context.staging()
    }
    
    func updatePayment(
        _ context: AnywayPaymentContext,
        _ update: AnywayPaymentUpdate
    ) -> AnywayPaymentContext {
        
        return context.update(with: update, and: context.outline)
    }
    
    func composeInspector() -> Inspector {
        
        return .init(
            checkFraud: { $0.details.control.isFraudSuspected },
            getVerificationCode: { $0.payment.otp },
            makeDigest: { $0.makeDigest() },
            resetPayment: { $0.resetPayment() },
            rollbackPayment: { $0.rollbackPayment() },
            validatePayment: validatePayment,
            wouldNeedRestart: { $0.wouldNeedRestart }
        )
    }
    
    private func validatePayment(
        context: AnywayPaymentContext
    ) -> Bool {
        
        let parameterValidator = AnywayPaymentParameterValidator()
        let validator = AnywayPaymentValidator(
            validateParameter: parameterValidator.validate
        )
        
        return validator.isValid(context.payment)
    }
    
    typealias Effect = TransactionEffect<AnywayPaymentDigest, AnywayPaymentEffect>
    typealias Inspector = PaymentInspector<AnywayPaymentContext, AnywayPaymentDigest, AnywayPaymentUpdate>
}

private extension AnywayPaymentContext {
    
    func update(
        with update: AnywayPaymentUpdate,
        and outline: AnywayPaymentOutline
    ) -> Self {
        
        let payment = payment.update(with: update, and: outline)
        
        return .init(
            initial: initial,
            payment: payment,
            staged: staged,
            outline: outline,
            shouldRestart: shouldRestart
        )
    }
}

private extension AnywayPayment {
    
    var otp: VerificationCode? {
        
        guard case let .widget(widget) = elements[id: .widgetID(.otp)],
              case let .otp(otp) = widget
        else { return nil }
        
        return otp.map { "\($0)" }
    }
}
