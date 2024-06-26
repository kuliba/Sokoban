//
//  AnywayPaymentWidgetViewFactory.swift
//  ForaBank
//
//  Created by Igor Malyarov on 14.06.2024.
//

import OTPInputComponent
import SwiftUI
import UIPrimitives

struct AnywayPaymentWidgetViewFactory {
    
    let makeOTPView: MakeOTPView
}

extension AnywayPaymentWidgetViewFactory {
    
    typealias OTPViewModel = TimedOTPInputViewModel
    typealias IconView = UIPrimitives.AsyncImage
    typealias OTPView = TimedOTPInputWrapperView<IconView, EmptyView>
    typealias MakeOTPView = (OTPViewModel) -> OTPView
}
