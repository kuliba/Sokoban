//
//  AnywayElement+uiComponent.swift
//
//
//  Created by Igor Malyarov on 06.04.2024.
//

import AnywayPaymentDomain

#warning("move to AnywayPaymentUI?")
extension AnywayElement {
    
    public var uiComponent: UIComponent {
        
        switch self {
        case let .field(field):
            return .field(.init(field))
            
        case let .parameter(parameter):
            return .parameter(parameter.uiComponent)
            
        case let .widget(widget):
            return widget.uiComponent
        }
    }
    
    public enum UIComponent: Equatable {
        
        case field(Field)
        case parameter(Parameter)
        case widget(Widget)
    }
}

extension AnywayElement.UIComponent {
    
    public struct Field: Equatable {
        
        public let name: String
        public let title: String
        public let value: String
        public let icon: Icon?
        
        public init(
            name: String,
            title: String,
            value: String,
            icon: Icon?
        ) {
            self.name = name
            self.title = title
            self.value = value
            self.icon = icon
        }
    }
    
    public struct Parameter: Equatable {
        
        public let id: ID
        public let type: ParameterType
        public let title: String
        public let subtitle: String?
        public let value: Value?
        public let icon: Icon?
        
        public init(
            id: ID,
            type: ParameterType,
            title: String,
            subtitle: String?,
            value: Value?,
            icon: Icon?
        ) {
            self.id = id
            self.type = type
            self.title = title
            self.subtitle = subtitle
            self.value = value
            self.icon = icon
        }
    }
    
    public enum Widget: Equatable {
        
        case info(AnywayElement.Widget.Info)
        case otp(Int?, String?)
        case productPicker(ProductID, ProductType)
        
        public typealias ProductID = AnywayElement.Widget.Product.ProductID
        public typealias ProductType = AnywayElement.Widget.Product.ProductType
    }
}

extension AnywayElement.UIComponent {
    
    public enum Icon: Equatable {
        
        case md5Hash(String)
        case svg(String)
        case withFallback(md5Hash: String, svg: String)
    }
}

extension AnywayElement.UIComponent.Parameter {
    
    public typealias ID = String
    
    public enum ParameterType: Equatable {
        
        case hidden
        case nonEditable
        case numberInput
        case select(Option, [Option])
        case textInput
        case unknown
    }
    
    public typealias Value = String
}

extension AnywayElement.UIComponent.Parameter.ParameterType {
    
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

extension AnywayElement.UIComponent.Parameter.ParameterType.Option {
    
    public typealias Key = String
    public typealias Value = String
}

extension AnywayElement.Parameter {
    
#warning("used in preview - fix, make private")
    public var uiComponent: AnywayElement.UIComponent.Parameter {
        
        .init(
            id: field.id,
            type: uiAttributes.parameterType,
            title: uiAttributes.title,
            subtitle: uiAttributes.subTitle,
            value: field.value.map { .init($0) },
            icon: icon.map { .init($0) }
        )
    }
}

// MARK: - Adapters

private extension AnywayElement.Parameter.UIAttributes {
    
    var parameterType: AnywayElement.UIComponent.Parameter.ParameterType {
        
        switch (type, viewType, dataType) {
        case (_, .constant, _):
            return .nonEditable
            
        case (_, .output, _):
            return .hidden
            
        case (.input, .input, .number):
            return .numberInput
            
        case (.input, .input, .string):
            return .textInput
            
        case let (.select, .input, .pairs(pair, pairs)):
            return .select(pair.option, pairs.map(\.option))
            
        default:
            return .unknown
        }
    }
}

private extension AnywayElement.Parameter.UIAttributes.DataType.Pair {
    
    var option: AnywayElement.UIComponent.Parameter.ParameterType.Option {
        
        .init(key: .init(key), value: .init(value))
    }
}

private extension AnywayElement.Widget {
    
    var uiComponent: AnywayElement.UIComponent {
        
        switch self {
        case let .info(info):
            return .widget(.info(info))
            
        case let .product(core):
            return .widget(.productPicker(core.productID, core.productType))
            
        case let .otp(otp, warning):
            return .widget(.otp(otp, warning))
        }
    }
}

private extension AnywayElement.UIComponent.Field {
    
    init(_ field: AnywayElement.Field) {
        
        self.init(
            name: field.id,
            title: field.title,
            value: field.value,
            icon: field.icon.map { .init($0) }
        )
    }
}

private extension AnywayElement.UIComponent.Icon {
    
    init(_ icon: AnywayElement.Icon) {
        
        switch icon {
            
        case let .md5Hash(md5Hash):
            self = .md5Hash(md5Hash)
            
        case let .svg(svg):
            self = .svg(svg)
            
        case let .withFallback(md5Hash: md5Hash, svg: svg):
            self = .withFallback(md5Hash: md5Hash, svg: svg)
        }
    }
}
