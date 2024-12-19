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
            handleOTPFailure: handleOTPFailure,
            makeDigest: { $0.makeDigest() },
            resetPayment: { $0.resetPayment() },
            rollbackPayment: { $0.rollbackPayment() },
            stagePayment: stagePayment,
            updatePayment: updatePayment,
            validatePayment: validatePayment,
            wouldNeedRestart: { $0.wouldNeedRestart }
        )
    }
    
    private func handleOTPFailure(
        context: AnywayPaymentContext,
        with message: String
    ) -> AnywayPaymentContext {
        
        let otpWidget = context.payment.elements[id: .widgetID(.otp)]
        
        guard case let .widget(.otp(value, _)) = otpWidget
        else { return context }
        
        var context = context
        context.payment.elements[id: .widgetID(.otp)] = .widget(.otp(value, message))
        
        return context
    }
    
    private func validatePayment(
        context: AnywayPaymentContext
    ) -> Bool {
        
        let validator = AnywayPaymentContextValidator()
        
        return validator.validate(context) == nil
    }
    
    typealias Effect = TransactionEffect<AnywayPaymentDigest, AnywayPaymentEffect>
    typealias Inspector = PaymentInspector<AnywayPaymentContext, AnywayPaymentDigest, AnywayPaymentUpdate>
}

private extension AnywayPaymentContext {
    
    func update(
        with update: AnywayPaymentUpdate,
        and outline: AnywayPaymentOutline
    ) -> Self {
        
        let outline = outline.updating(with: update)
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
              case let .otp(otp, _) = widget
        else { return nil }
        
        return otp.map { "\($0)" }
    }
}
