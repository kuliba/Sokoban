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
        elements.updatePrimaryFields(from: update.fields)
        elements.appendComplementaryFields(from: update.fields)
        elements.appendParameters(from: update.parameters, with: outline)
        
        elements.adjustWidget(.product(.init(outline.core)), on: update.details.control.needSum && !update.details.control.isMultiSum)
        elements.adjustWidget(.otp(nil), on: update.details.control.needOTP)
        
        let footer = footer.update(with: update, and: outline)
        
        return .init(
            elements: elements,
            footer: footer,
            infoMessage: update.details.info.infoMessage,
            isFinalStep: update.details.control.isFinalStep
        )
    }
}

private extension AnywayPayment.Footer {
    
    func update(
        with update: AnywayPaymentUpdate,
        and outline: AnywayPaymentOutline
    ) -> Self {
        
        if update.details.control.needSum
            && !update.details.control.isMultiSum {
            return .amount(outline.core.amount)
        } else {
            return .continue
        }
    }
}

private extension AnywayElement.Widget.Product {
    
    init(_ core: AnywayPaymentOutline.PaymentCore) {
        
        self.init(
            currency: core.currency,
            productID: core.productID,
            productType: core._productType
        )
    }
}

private extension AnywayPaymentOutline.PaymentCore {
    
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
        
        .init(
            id: id,
            title: fieldUpdate.title,
            value: fieldUpdate.value,
            image: fieldUpdate.image.map { .init($0) }
        )
    }
}

private extension AnywayElement.Image {
    
    init(_ image: AnywayPaymentUpdate.Image) {
        
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
            image: image,
            masking: masking,
            validation: validation,
            uiAttributes: uiAttributes
        )
    }
}

private extension Array where Element == AnywayElement {
    
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
            image: field.image.map { .init($0) }
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
            image: .init(parameter),
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

private extension AnywayElement.Image {
    
    init?(_ parameter: AnywayPaymentUpdate.Parameter) {
        
        switch parameter.image {
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
