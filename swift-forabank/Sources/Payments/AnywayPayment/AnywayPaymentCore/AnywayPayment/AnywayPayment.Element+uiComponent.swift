//
//  AnywayPayment.Element+uiComponent.swift
//
//
//  Created by Igor Malyarov on 06.04.2024.
//

import Tagged

extension AnywayPayment.Element {
    
    public var uiComponent: AnywayPayment.UIComponent {
        
        switch self {
        case let .field(field):
            return .field(.init(field))
            
        case let .parameter(parameter):
            return .parameter(parameter.uiComponent)
            
        case let .widget(widget):
            return widget.uiComponent
        }
    }
}

extension AnywayPayment {
    
    public enum UIComponent: Equatable {
        
        case field(Field)
        case parameter(Parameter)
        case widget(Widget)
    }
}

extension AnywayPayment.UIComponent {
    
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
    
    public struct Parameter: Equatable {
        
        public let id: ID
        public let type: ParameterType
        public let value: Value?
        
        public init(
            id: ID,
            type: ParameterType,
            value: Value?
        ) {
            self.id = id
            self.type = type
            self.value = value
        }
    }
    
    public enum Widget: Equatable {
        
        case otp(Int?)
        case productPicker(ProductID)
    }
}

extension AnywayPayment.UIComponent.Parameter {
    
    public typealias ID = Tagged<_ID, String>
    public enum _ID {}
    
    public enum ParameterType: Equatable {
        
        case hidden
        case nonEditable
        case select(Option, [Option])
        case textInput
        case unknown
    }
    
    public typealias Value = Tagged<_Value, String>
    public enum _Value {}
}

extension AnywayPayment.UIComponent.Parameter.ParameterType {
    
    public struct Option: Equatable {
        
        public let key: Key
        public let value: Value
        
        public init(
            key: Key,
            value: Value
        ) {
            self.key = key
            self.value = value
        }
    }
}

extension AnywayPayment.UIComponent.Parameter.ParameterType.Option {
    
    public typealias Key = Tagged<_Key, String>
    public enum _Key {}
    
    public typealias Value = Tagged<_Value, String>
    public enum _Value {}
}

extension AnywayPayment.Element.Parameter {
    
#warning("used in preview - fix, make private")
    public var uiComponent: AnywayPayment.UIComponent.Parameter {
        
        .init(
            id: .init(field.id.rawValue),
            type: uiAttributes.uiComponent,
            value: field.value.map { .init($0.rawValue) }
        )
    }
}

extension AnywayPayment.UIComponent.Widget {
    
    public typealias ProductID = AnywayPayment.Element.Widget.PaymentCore.ProductID
}

private extension AnywayPayment.Element.Parameter.UIAttributes {
    
    var uiComponent: AnywayPayment.UIComponent.Parameter.ParameterType {
        
        switch (type, viewType, dataType) {
        case (_, .constant, _):
            return .nonEditable
            
        case (_, .output, _):
            return .hidden
            
        case (.input, .input, .string):
            return .textInput
            
        case let (.select, .input, .pairs(pair, pairs)):
            return .select(pair.option, pairs.map(\.option))
            
        default:
            return .unknown
        }
    }
}

private extension AnywayPayment.Element.Parameter.UIAttributes.DataType.Pair {
    
    var option: AnywayPayment.UIComponent.Parameter.ParameterType.Option {
        
        .init(key: .init(key), value: .init(value))
    }
}

private extension AnywayPayment.Element.Widget {
    
    var uiComponent: AnywayPayment.UIComponent {
        
        switch self {
        case let .core(core):
            return .widget(.productPicker(core.productID))
            
        case let .otp(otp):
            return .widget(.otp(otp))
        }
    }
}

private extension AnywayPayment.UIComponent.Field {
    
    init(_ field: AnywayPayment.Element.Field) {
        
        self.init(
            name: field.id.rawValue,
            title: field.title,
            value: field.value.rawValue
        )
    }
}
