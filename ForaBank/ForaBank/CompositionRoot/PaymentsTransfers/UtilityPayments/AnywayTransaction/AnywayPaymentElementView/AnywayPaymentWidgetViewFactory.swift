//
//  AnywayPaymentWidgetViewFactory.swift
//  ForaBank
//
//  Created by Igor Malyarov on 14.06.2024.
//

import PaymentComponents

struct AnywayPaymentWidgetViewFactory {
    
    let makeOTPView: MakeOTPView
}

extension AnywayPaymentWidgetViewFactory {
    
    typealias OTPViewModel = TimedOTPInputViewModel
    typealias MakeOTPView = (OTPViewModel) -> TimedOTPInputWrapperView
}
