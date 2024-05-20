//
//  AnywayPayment.Element+Identifiable.swift
//  TransactionPreview
//
//  Created by Igor Malyarov on 20.05.2024.
//

import AnywayPaymentDomain

#warning("extract to module")
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
