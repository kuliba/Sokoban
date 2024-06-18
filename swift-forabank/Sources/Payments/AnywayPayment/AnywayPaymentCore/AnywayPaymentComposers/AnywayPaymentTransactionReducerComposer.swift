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
            paymentReduce: paymentReduce,
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
    
    func paymentReduce(
        _ state: AnywayPaymentContext,
        _ event: AnywayPaymentEvent
    ) -> (AnywayPaymentContext, Effect?) {
        
        let paymentReducer = AnywayPaymentReducer()
        let (payment, effect): (AnywayPayment, AnywayPaymentReducer.Effect?) = paymentReducer.reduce(state.payment, event)
        let state = AnywayPaymentContext(
            payment: payment,
            staged: state.staged,
            outline: state.outline,
            shouldRestart: state.shouldRestart
        )
        
        return (state, effect.map(Effect.payment))
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
            checkFraud: { $0.payment.isFraudSuspected },
            getVerificationCode: { $0.payment.otp },
            makeDigest: { $0.makeDigest() },
            restorePayment: { $0.restorePayment() },
            validatePayment: validatePayment,
            wouldNeedRestart: { $0.wouldNeedRestart }
        )
    }
    
    private func validatePayment(
        context: AnywayPaymentContext
    ) -> Bool {
        
        let parameterValidator = AnywayPaymentParameterValidator()
        let validator = AnywayPaymentValidator(
            isValidParameter: parameterValidator.isValid(_:)
        )
        
        return validator.isValid(context.payment)
    }
    
    typealias Effect = TransactionEffect<AnywayPaymentDigest, AnywayPaymentEffect>
    typealias Inspector = PaymentInspector<AnywayPaymentContext, AnywayPaymentDigest>
}

private extension AnywayPaymentContext {
    
    func update(
        with update: AnywayPaymentUpdate,
        and outline: AnywayPaymentOutline
    ) -> Self {
        
        let payment = payment.update(with: update, and: outline)
        
        return .init(payment: payment, staged: staged, outline: outline, shouldRestart: shouldRestart)
    }
}

private extension AnywayPayment {
    
    var otp: VerificationCode? {
        
        guard case let .widget(otp) = elements[id: .widgetID(.otp)],
              case let .otp(otp) = otp
        else { return nil }
        
        return otp.map { "\($0)" }
    }
}
