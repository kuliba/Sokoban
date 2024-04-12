//
//  AnywayPayment.Element+uiComponentType.swift
//
//
//  Created by Igor Malyarov on 06.04.2024.
//

extension AnywayPayment.Element {
    
    public var uiComponentType: AnywayPayment.UIComponentType {
        
        switch self {
        case let .field(field):
            return .field(.init(field))
            
        case let .parameter(parameter):
            return parameter.uiComponentType
            
        case let .widget(widget):
            return widget.uiComponentType
        }
    }
}

extension AnywayPayment {
    
    public enum UIComponentType: Equatable {
        
        case field(Field)
        case otp, productPicker
    }
}

extension AnywayPayment.UIComponentType {
    
    public struct Field: Equatable {
        
        public let name: String
        public let title: String
        public let value: String
        
        public init(
            name: String, 
            title: String,
            value: String
        ) {
            self.name = name
            self.title = title
            self.value = value
        }
    }
}

private extension AnywayPayment.Element.Parameter {
    
    var uiComponentType: AnywayPayment.UIComponentType {
        
        uiAttributes.uiComponentType
    }
}

private extension AnywayPayment.Element.Parameter.UIAttributes {
    
    var uiComponentType: AnywayPayment.UIComponentType {
        
        fatalError()
    }
}

private extension AnywayPayment.Element.Widget {
    
    var uiComponentType: AnywayPayment.UIComponentType {
        
        switch self {
        case .core:
            return .productPicker
            
        case .otp:
            return .otp
        }
    }
}

private extension AnywayPayment.UIComponentType.Field {
    
    init(_ field: AnywayPayment.Element.Field) {
        
        self.init(
            name: field.id.rawValue,
            title: field.title,
            value: field.value.rawValue
        )
    }
}
