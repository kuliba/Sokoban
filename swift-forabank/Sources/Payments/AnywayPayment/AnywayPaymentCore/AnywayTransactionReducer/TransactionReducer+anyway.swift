//
//  TransactionReducer+anyway.swift
//
//
//  Created by Igor Malyarov on 21.05.2024.
//

import AnywayPaymentDomain

public extension TransactionReducer
where Payment == AnywayPaymentContext,
      PaymentEvent == AnywayPaymentEvent,
      PaymentEffect == AnywayPaymentEffect,
      PaymentDigest == AnywayPaymentDigest,
      PaymentUpdate == AnywayPaymentUpdate {
    
    static func anyway(
    ) -> Self {
        
        return .init(
            paymentReduce: paymentReduce,
            stagePayment: stagePayment,
            updatePayment: updatePayment,
            paymentInspector: .default
        )
    }
    
    private static func paymentReduce(
        _ state: AnywayPaymentContext,
        _ event: AnywayPaymentEvent
    ) -> (AnywayPaymentContext, Effect?) {
        
        let paymentReducer = AnywayPaymentReducer()
        let (payment, effect): (AnywayPayment, AnywayPaymentReducer.Effect?) = paymentReducer.reduce(state.payment, event)
        let state = AnywayPaymentContext(
            payment: payment,
            staged: state.staged,
            outline: state.outline
        )
        
        return (state, effect.map(Effect.payment))
    }
    
    private static func stagePayment(
        _ context: AnywayPaymentContext
    ) -> AnywayPaymentContext {
        
        context.staging()
    }
    
    private static func updatePayment(
        _ context: AnywayPaymentContext,
        _ update: AnywayPaymentUpdate
    ) -> AnywayPaymentContext {
        
        return context.update(with: update, and: context.outline)
    }
}

extension AnywayPaymentContext {
    
    func update(
        with update: AnywayPaymentUpdate,
        and outline: AnywayPaymentOutline
    ) -> Self {
        
        let payment = payment.update(with: update, and: outline)
        
        return .init(payment: payment, staged: staged, outline: outline)
    }
}

extension PaymentInspector
where Payment == AnywayPaymentContext,
      PaymentDigest == AnywayPaymentDigest {
    
    static var `default`: Self {
        
        return .init(
            checkFraud: { $0.payment.isFraudSuspected },
            getVerificationCode: { $0.payment.otp },
            makeDigest: { $0.payment.makeDigest() },
            shouldRestartPayment: { _ in
                
#warning("FIXME")
                return false
            },
            validatePayment: { _ in
                
#warning("FIXME")
                return true
            }
        )
    }
}

extension AnywayPayment.Element: Identifiable {
    
    public var id: ID {
        
        switch self {
        case let .field(field):
            return .fieldID(field.id)
            
        case let .parameter(parameter):
            return .parameterID(parameter.field.id)
            
        case let .widget(widget):
            return .widgetID(widget.id)
        }
    }
    
    public enum ID: Hashable {
        
        case fieldID(Field.ID)
        case parameterID(Parameter.Field.ID)
        case widgetID(Widget.ID)
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
