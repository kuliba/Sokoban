//
//  AnywayPayment+update.swift
//
//
//  Created by Igor Malyarov on 06.04.2024.
//

import Foundation
import Tagged

extension AnywayPayment {
    
    public func update(
        with update: AnywayPaymentUpdate,
        and outline: Outline
    ) -> Self {
        
        var elements = elements
        elements.updatePrimaryFields(from: update.fields)
        elements.appendComplementaryFields(from: update.fields)
        elements.appendParameters(from: update.parameters, with: outline)
        
        elements.adjustWidget(.core(.init(outline.core)), on: update.details.control.needSum)
        elements.adjustWidget(.otp(nil), on: update.details.control.needOTP)
        
        return .init(
            elements: elements,
            infoMessage: update.details.info.infoMessage,
            isFinalStep: update.details.control.isFinalStep,
            isFraudSuspected: update.details.control.isFraudSuspected,
            puref: puref
        )
    }
    
    public struct Outline: Equatable {
        
        public let core: PaymentCore
        public let fields: Fields
        
        public init(
            core: PaymentCore,
            fields: Fields
        ) {
            self.core = core
            self.fields = fields
        }
    }
}

extension AnywayPayment.Outline {
    
    public typealias Fields = [ID: Value]
    
    public typealias ID = Tagged<_ID, String>
    public enum _ID {}
    
    public typealias Value = Tagged<_Value, String>
    public enum _Value {}

    public struct PaymentCore: Equatable {
        
        public let amount: Decimal
        public let currency: String
        public let productID: Int
        public let productType: ProductType
        
        public init(
            amount: Decimal,
            currency: String,
            productID: Int,
            productType: ProductType
        ) {
            self.amount = amount
            self.currency = currency
            self.productID = productID
            self.productType = productType
        }
    }
}

extension AnywayPayment.Outline.PaymentCore {
    
    public enum ProductType {
        
        case account, card
    }
}

private extension AnywayPayment.Element.Widget.PaymentCore {
    
    init(_ core: AnywayPayment.Outline.PaymentCore) {
        
        self.init(
            amount: core.amount,
            currency: .init(core.currency),
            productID: .init(core)
        )
    }
}

private extension AnywayPayment.Element.Widget.PaymentCore.ProductID {
    
    init(_ core: AnywayPayment.Outline.PaymentCore) {
        
        switch core.productType {
        case .account: self = .accountID(.init(core.productID))
        case .card:    self = .cardID(.init(core.productID))
        }
    }
}

private extension AnywayPayment.Element {
    
    var stringID: String? {
        
        switch self {
        case let .field(field):
            return field.id.rawValue
            
        case let .parameter(parameter):
            return parameter.field.id.rawValue
            
        case .widget:
            return nil
        }
    }
    
    var widgetID: Widget.ID? {
        
        guard case let .widget(widget) = self else { return nil }
        
        return widget.id
    }

    func updating(with fieldUpdate: AnywayPaymentUpdate.Field) -> Self {
        
        switch self {
        case let .field(field):
            return .field(field.updating(with: fieldUpdate))
            
        case let .parameter(parameter):
            return .parameter(parameter.updating(with: fieldUpdate))
            
        case .widget:
            return self
        }
    }
}

private extension AnywayPayment.Element.Field {
    
    func updating(with fieldUpdate: AnywayPaymentUpdate.Field) -> Self {
        
        .init(
            id: id,
            title: fieldUpdate.title,
            value: .init(fieldUpdate.value)
        )
    }
}

private extension AnywayPayment.Element.Parameter {
    
    func updating(with fieldUpdate: AnywayPaymentUpdate.Field) -> Self {
        
        .init(
            field: .init(
                id: field.id,
                value: .init(fieldUpdate.value)
            ),
            masking: masking,
            validation: validation,
            uiAttributes: uiAttributes
        )
    }
}

private extension Array where Element == AnywayPayment.Element {
    
    mutating func adjustWidget(
        _ widget: Element.Widget,
        on condition: Bool
    ) {
        update(widgetID: widget.id, with: condition ? widget : nil)
    }
    
    private mutating func update(
        widgetID: Element.Widget.ID,
        with widget: Element.Widget?
    ) {
        if let index = firstIndex(matching: widgetID) {
            if let widget {
                if widget.id == widgetID {
                    self[index] = .widget(widget)
                } else {
                    append(.widget(widget))
                }
            } else {
                remove(at: index)
            }
        } else {
            if let widget {
                append(.widget(widget))
            }
        }
    }
    
    private func firstIndex(
        matching id: Element.Widget.ID
    ) -> Self.Index? {
        
        firstIndex {
            
            guard let widgetID = $0.widgetID else { return false }
            
            return widgetID == id
        }
    }
    
    mutating func updatePrimaryFields(
        from updateFields: [AnywayPaymentUpdate.Field]
    ) {
        let updateFields = Dictionary(
            uniqueKeysWithValues: updateFields.map { ($0.name, $0) }
        )
        
        self = map {
            
            guard let id = $0.stringID,
                  let matching = updateFields[id]
            else { return $0 }
            
            return $0.updating(with: matching)
        }
    }
    
    mutating func appendComplementaryFields(
        from updateFields: [AnywayPaymentUpdate.Field]
    ) {
        let existingIDs = compactMap(\.stringID)
        let complimentary: [Element] = updateFields
            .filter { !existingIDs.contains($0.name) }
            .map(Element.Field.init)
            .map(Element.field)
        
        self.append(contentsOf: complimentary)
    }
    
    mutating func appendParameters(
        from updateParameters: [AnywayPaymentUpdate.Parameter],
        with outline: AnywayPayment.Outline
    ) {
        let parameters = updateParameters.map {
            
            AnywayPayment.Element.Parameter(
                parameter: $0,
                fallbackValue: outline.fields[.init($0.field.id)]
            )
        }
        append(contentsOf: parameters.map(Element.parameter))
    }
}

// MARK: - Adapters

private extension AnywayPayment.Element.Field {
    
    init(_ field: AnywayPaymentUpdate.Field) {
        
        self.init(
            id: .init(field.name),
            title: field.title,
            value: .init(field.value)
        )
    }
}

private extension AnywayPayment.Element.Parameter {
    
    init(
        parameter: AnywayPaymentUpdate.Parameter,
        fallbackValue: AnywayPayment.Outline.Value?
    ) {
        self.init(
            field: .init(parameter.field, fallbackValue: fallbackValue),
            masking: .init(parameter.masking),
            validation: .init(parameter.validation),
            uiAttributes: .init(parameter.uiAttributes)
        )
    }
}

private extension AnywayPayment.Element.Parameter.Field {
    
    init(
        _ field: AnywayPaymentUpdate.Parameter.Field,
        fallbackValue: AnywayPayment.Outline.Value?
    ) {
        self.init(
            id: .init(field.id),
            value: field.content.map { .init($0) } ?? fallbackValue.map { .init($0.rawValue) }
        )
    }
}

private extension AnywayPayment.Element.Parameter.Masking {
    
    init(_ masking: AnywayPaymentUpdate.Parameter.Masking) {
        
        self.init(inputMask: masking.inputMask, mask: masking.mask)
    }
}

private extension AnywayPayment.Element.Parameter.Validation {
    
    init(_ validation: AnywayPaymentUpdate.Parameter.Validation) {
        
        self.init(
            isRequired: validation.isRequired,
            maxLength: validation.maxLength,
            minLength: validation.minLength,
            regExp: validation.regExp
        )
    }
}

private extension AnywayPayment.Element.Parameter.UIAttributes {
    
    init(_ uiAttributes: AnywayPaymentUpdate.Parameter.UIAttributes) {
        
        self.init(
            dataType: .init(uiAttributes.dataType),
            group: uiAttributes.group,
            isPrint: uiAttributes.isPrint,
            phoneBook: uiAttributes.phoneBook,
            isReadOnly: uiAttributes.isReadOnly,
            subGroup: uiAttributes.subGroup,
            subTitle: uiAttributes.subTitle,
            svgImage: uiAttributes.svgImage,
            title: uiAttributes.title,
            type: .init(uiAttributes.type),
            viewType: .init(uiAttributes.viewType)
        )
    }
}

private extension AnywayPayment.Element.Parameter.UIAttributes.DataType {
    
    init(_ dataType: AnywayPaymentUpdate.Parameter.UIAttributes.DataType) {
        
        switch dataType {
        case .string:
            self = .string
            
        case let .pairs(pair, pairs):
            self = .pairs(pair.pair, pairs.map(\.pair))
        }
    }
}

private extension AnywayPaymentUpdate.Parameter.UIAttributes.DataType.Pair {
    
    var pair: AnywayPayment.Element.Parameter.UIAttributes.DataType.Pair {
        
        .init(key: key, value: value)
    }
}

private extension AnywayPayment.Element.Parameter.UIAttributes.FieldType {
    
    init(_ fieldType: AnywayPaymentUpdate.Parameter.UIAttributes.FieldType) {
        
        switch fieldType {
        case .input:    self = .input
        case .select:   self = .select
        case .maskList: self = .maskList
        }
    }
}

private extension AnywayPayment.Element.Parameter.UIAttributes.ViewType {
    
    init(_ viewType: AnywayPaymentUpdate.Parameter.UIAttributes.ViewType) {
        
        switch viewType {
        case .constant: self = .constant
        case .input:    self = .input
        case .output:   self = .output
        }
    }
}
