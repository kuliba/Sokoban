//
//  AnywayPayment+update.swift
//
//
//  Created by Igor Malyarov on 06.04.2024.
//

import Foundation
import Tagged
import AnywayPaymentDomain

extension AnywayPayment {
    
    public func update(
        with update: AnywayPaymentUpdate,
        and outline: AnywayPaymentOutline
    ) -> Self {
        
        var elements = elements
        elements.updateExistingElements(with: update.fields)
        elements.appendNewFields(from: update.fields)
        elements.appendNewParameters(from: update.parameters, with: outline)
        
        if let product = outline.product {
            
            elements.addIfMissing(
                widget: .product(.init(product)),
                condition: update.details.control.needSum
            )
        }
        
        elements.addIfMissing(
            widget: .info(.init(update)),
            condition: update.details.control.needOTP
        )
        
        elements.addIfMissing(
            widget: .otp(nil, nil),
            condition: update.details.control.needOTP
        )
        
        let footer = update.makeFooter()
        
        return .init(
            amount: update.details.amounts.amount ?? amount,
            elements: elements,
            footer: footer,
            isFinalStep: update.details.control.isFinalStep
        )
    }
}

private extension AnywayElement.Widget.Info {
    
    init(_ update: AnywayPaymentUpdate) {
        
        self.init(
            currency: update.details.amounts.currencyPayer,
            fields: [
                update.details.amounts.amount.map { .amount($0) },
                update.details.amounts.fee.map { .fee($0) },
                update.details.amounts.debitAmount.map { .total($0) }
            ].compactMap { $0 }
        )
    }
}

private extension AnywayPaymentUpdate {
    
    func makeFooter() -> AnywayPayment.Footer {
        
        guard !details.control.isFinalStep else { return .continue }
        
        return needSum && !isMultiSum ? .amount : .continue
    }
}

private extension AnywayPaymentUpdate {
    
    var needSum: Bool { details.control.needSum }
    var isMultiSum: Bool { details.control.isMultiSum }
}

private extension AnywayElement.Widget.Product {
    
    init(_ core: AnywayPaymentOutline.Product) {
        
        self.init(
            currency: core.currency,
            productID: core.productID,
            productType: core._productType
        )
    }
}

private extension AnywayPaymentOutline.Product {
    
    var _productType: AnywayElement.Widget.Product.ProductType {
        
        switch productType {
        case .account: return .account
        case .card:    return .card
        }
    }
}

private extension AnywayElement {
    
    var stringID: String? {
        
        switch self {
        case let .field(field):
            return field.id
            
        case let .parameter(parameter):
            return parameter.field.id
            
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

private extension AnywayElement.Field {
    
    func updating(with fieldUpdate: AnywayPaymentUpdate.Field) -> Self {
        
        return .init(
            id: id,
            title: fieldUpdate.title,
            value: fieldUpdate.value,
            icon: fieldUpdate.icon.map { .init($0) }
        )
    }
}

private extension AnywayElement.Icon {
    
    init(_ image: AnywayPaymentUpdate.Icon) {
        
        switch image {
            
        case let .md5Hash(md5Hash):
            self = .md5Hash(md5Hash)
            
        case let .svg(svg):
            self = .svg(svg)
            
        case let .withFallback(md5Hash: md5Hash, svg: svg):
            self = .withFallback(md5Hash: md5Hash, svg: svg)
        }
    }
}

private extension AnywayElement.Parameter {
    
    func updating(with fieldUpdate: AnywayPaymentUpdate.Field) -> Self {
        
        return .init(
            field: .init(
                id: field.id,
                value: fieldUpdate.value
            ),
            icon: icon,
            masking: masking,
            validation: validation,
            uiAttributes: uiAttributes
        )
    }
}

private extension Array where Element == AnywayElement {
    
    mutating func addIfMissing(
        widget: Element.Widget,
        condition: Bool
    ) {
        guard isMissing(widget) else { return }
        
        if condition {
            append(.widget(widget))
        }
    }
    
    private func isMissing(
        _ widget: Element.Widget
    ) -> Bool {
        
        let first = first {
            
            guard let widgetID = $0.widgetID else { return false }
            
            return widgetID == widget.id
        }
        
        return first == nil
    }
    
    mutating func updateExistingElements(
        with updateFields: [AnywayPaymentUpdate.Field]
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
    
    mutating func appendNewFields(
        from updateFields: [AnywayPaymentUpdate.Field]
    ) {
        let existingIDs = compactMap(\.stringID)
        let newFields: [Element] = updateFields
            .filter { !existingIDs.contains($0.name) }
            .map(Element.Field.init)
            .map(Element.field)
        
        self.append(contentsOf: newFields)
    }
    
    mutating func appendNewParameters(
        from updateParameters: [AnywayPaymentUpdate.Parameter],
        with outline: AnywayPaymentOutline
    ) {
        let parameters = updateParameters.map {
            
            AnywayElement.Parameter(
                parameter: $0,
                fallbackValue: outline.fields[$0.field.id]
            )
        }
        append(contentsOf: parameters.map(Element.parameter))
    }
}

// MARK: - Adapters

private extension AnywayElement.Field {
    
    init(_ field: AnywayPaymentUpdate.Field) {
        
        self.init(
            id: field.name,
            title: field.title,
            value: field.value,
            icon: field.icon.map { .init($0) }
        )
    }
}

private extension AnywayElement.Parameter {
    
    init(
        parameter: AnywayPaymentUpdate.Parameter,
        fallbackValue: AnywayPaymentOutline.Value?
    ) {
        self.init(
            field: .init(
                parameter.field,
                // TODO: add tests
                fallbackValue: parameter.selectedValue ?? fallbackValue
            ),
            icon: .init(parameter),
            masking: .init(parameter.masking),
            validation: .init(parameter.validation),
            uiAttributes: .init(parameter.uiAttributes)
        )
    }
}

private extension AnywayPaymentUpdate.Parameter {
    
    var selectedValue: String? {
        
        guard case let .pairs(pair, _) = uiAttributes.dataType
        else { return nil }
        
        return pair.key
    }
}

private extension AnywayElement.Icon {
    
    init?(_ parameter: AnywayPaymentUpdate.Parameter) {
        
        switch parameter.icon {
        case .none:
            return nil
            
        case let .md5Hash(md5Hash):
            self = .md5Hash(md5Hash)
            
        case let .svg(svg):
            self = .svg(svg)
            
        case let .withFallback(md5Hash, svg):
            self = .withFallback(md5Hash: md5Hash, svg: svg)
        }
    }
}

private extension AnywayElement.Parameter.Field {
    
    init(
        _ field: AnywayPaymentUpdate.Parameter.Field,
        fallbackValue: AnywayPaymentOutline.Value?
    ) {
        self.init(
            id: .init(field.id),
            value: field.content ?? fallbackValue.map { $0 }
        )
    }
}

private extension AnywayElement.Parameter.Masking {
    
    init(_ masking: AnywayPaymentUpdate.Parameter.Masking) {
        
        self.init(inputMask: masking.inputMask, mask: masking.mask)
    }
}

private extension AnywayElement.Parameter.Validation {
    
    init(_ validation: AnywayPaymentUpdate.Parameter.Validation) {
        
        self.init(
            isRequired: validation.isRequired,
            maxLength: validation.maxLength,
            minLength: validation.minLength,
            regExp: validation.regExp
        )
    }
}

private extension AnywayElement.Parameter.UIAttributes {
    
    init(_ uiAttributes: AnywayPaymentUpdate.Parameter.UIAttributes) {
        
        self.init(
            dataType: .init(uiAttributes.dataType),
            group: uiAttributes.group,
            isPrint: uiAttributes.isPrint,
            phoneBook: uiAttributes.phoneBook,
            isReadOnly: uiAttributes.isReadOnly,
            subGroup: uiAttributes.subGroup,
            subTitle: uiAttributes.subTitle,
            title: uiAttributes.title,
            type: .init(uiAttributes.type),
            viewType: .init(uiAttributes.viewType)
        )
    }
}

private extension AnywayElement.Parameter.UIAttributes.DataType {
    
    init(_ dataType: AnywayPaymentUpdate.Parameter.UIAttributes.DataType) {
        
        switch dataType {
        case ._backendReserved:
            self = ._backendReserved
            
        case .number:
            self = .number
            
        case let .pairs(pair, pairs):
            self = .pairs(pair.pair, pairs.map(\.pair))
            
        case .string:
            self = .string
        }
    }
}

private extension AnywayPaymentUpdate.Parameter.UIAttributes.DataType.Pair {
    
    var pair: AnywayElement.Parameter.UIAttributes.DataType.Pair {
        
        .init(key: key, value: value)
    }
}

private extension AnywayElement.Parameter.UIAttributes.FieldType {
    
    init(_ fieldType: AnywayPaymentUpdate.Parameter.UIAttributes.FieldType) {
        
        switch fieldType {
        case .input:    self = .input
        case .select:   self = .select
        case .maskList: self = .maskList
        case .missing:  self = .missing
        }
    }
}

private extension AnywayElement.Parameter.UIAttributes.ViewType {
    
    init(_ viewType: AnywayPaymentUpdate.Parameter.UIAttributes.ViewType) {
        
        switch viewType {
        case .constant: self = .constant
        case .input:    self = .input
        case .output:   self = .output
        }
    }
}
