//
//  PaymentInspector+default.swift
//  TransactionPreview
//
//  Created by Igor Malyarov on 20.05.2024.
//

import AnywayPaymentCore
import AnywayPaymentDomain
import ForaTools

#warning("extract to module?")

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

private extension AnywayPayment {
    
    var otp: VerificationCode? {
        
        guard case let .widget(otp) = elements[id: .widgetID(.otp)],
              case let .otp(otp) = otp
        else { return nil }
        
        return otp.map { "\($0)" }
    }
}
