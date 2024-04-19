//
//  ComposedAnywayPaymentViewFactory.swift
//  AnywayPaymentPreview
//
//  Created by Igor Malyarov on 16.04.2024.
//

import AnywayPaymentCore
import SwiftUI

struct ComposedAnywayPaymentViewFactory<FieldView, OTPView, ParameterView, ProductPicker> {
    
    let fieldView: MakeFieldView
    let otpView: MakeOTPView
    let parameterView: MakeParameterView
    let productPicker: MakeProductPicker
}

extension ComposedAnywayPaymentViewFactory {
    
    typealias MakeFieldView = (Field) -> FieldView
    typealias MakeOTPView = (String, @escaping (String) -> Void) -> OTPView
    typealias MakeParameterView = (Parameter, @escaping (String) -> Void) -> ParameterView
    typealias MakeProductPicker = (AnywayPayment.Element.UIComponent.Widget.ProductID, @escaping (AnywayPaymentEvent.Widget.ProductID, AnywayPaymentEvent.Widget.Currency) -> Void) -> ProductPicker
    
    typealias Field = AnywayPayment.Element.UIComponent.Field
    typealias Parameter = AnywayPayment.Element.UIComponent.Parameter
}
