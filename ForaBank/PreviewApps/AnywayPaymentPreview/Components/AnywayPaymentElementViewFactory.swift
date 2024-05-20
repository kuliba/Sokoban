//
//  AnywayPaymentElementViewFactory.swift
//  AnywayPaymentPreview
//
//  Created by Igor Malyarov on 16.04.2024.
//

import AnywayPaymentDomain
import SwiftUI

struct AnywayPaymentElementViewFactory<FieldView, ParameterView, WidgetView> {
    
    let fieldView: MakeFieldView
    let parameterView: MakeParameterView
    let widgetView: MakeWidgetView
}

extension AnywayPaymentElementViewFactory {
    
    typealias MakeFieldView = (Field) -> FieldView
    typealias MakeParameterView = (Parameter, @escaping (String) -> Void) -> ParameterView
    typealias MakeWidgetView = (Widget, @escaping (AnywayPaymentEvent.Widget) -> Void) -> WidgetView
    
    typealias Field = AnywayPayment.Element.UIComponent.Field
    typealias Parameter = AnywayPayment.Element.UIComponent.Parameter
    typealias Widget = AnywayPayment.Element.UIComponent.Widget
}
