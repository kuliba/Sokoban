//
//  AnywayPaymentTransactionReducerTestHelpers.swift
//  
//
//  Created by Igor Malyarov on 18.06.2024.
//

import AnywayPaymentDomain

extension Transaction where Context == AnywayPaymentContext {
    
    var elementIDs: [AnywayElement.ID] { context.elementIDs }
    
    var parameters: [AnywayElement.Parameter] { context.parameters }
    var parameterIDs: [AnywayElement.Parameter.Field.ID] { context.parameterIDs }
    
    var widgets: [AnywayElement.Widget] { context.widgets }
    var widgetIDs: [AnywayElement.Widget.ID] { widgets.map(\.id) }
}

extension AnywayPaymentContext {
    
    var elementIDs: [AnywayElement.ID] { payment.elements.map(\.id) }
    
    var parameters: [AnywayElement.Parameter] {
        
        payment.elements.compactMap {
            
            guard case let .parameter(parameter) = $0 else { return nil }
            
            return parameter
        }
    }
    
    var parameterIDs: [AnywayElement.Parameter.Field.ID] {
        
        parameters.map(\.field.id)
    }
    
    var widgets: [AnywayElement.Widget] {
        
        payment.elements.compactMap {
            
            guard case let .widget(widget) = $0 else { return nil }
            
            return widget
        }
    }
    
    var widgetIDs: [AnywayElement.Widget.ID] { widgets.map(\.id) }
}
