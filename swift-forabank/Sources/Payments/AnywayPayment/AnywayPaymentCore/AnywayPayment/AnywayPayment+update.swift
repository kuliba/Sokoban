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
        
        let otp = Element.Field(id: .otp, value: "", title: "")
        elements[fieldID: .otp] = update.details.control.needOTP ? .field(otp) : nil
                
        return .init(
            elements: elements,
            hasAmount: update.details.control.needSum,
            infoMessage: update.details.info.infoMessage,
            isFinalStep: update.details.control.isFinalStep,
            isFraudSuspected: update.details.control.isFraudSuspected
        )
    }
    
    public typealias Outline = [Element.StringID: Element.Value]
}

private extension AnywayPayment.Element {
    
    var fieldID: Field.ID? {
        
        guard case let .field(field) = self else { return nil }
        
        return field.id
    }
    
    var stringID: StringID? {
        
        switch self {
        case let .field(field):
            switch field.id {
            case .otp:
                return nil
                
            case let .string(id):
                return id
            }
            
        case let .parameter(parameter):
            return parameter.field.id
        }
    }
}

private extension AnywayPayment.Element.Field {
    
    func updating(with fieldUpdate: AnywayPaymentUpdate.Field) -> Self {
        
        .init(
            id: id,
            value: .init(fieldUpdate.value),
            title: fieldUpdate.title
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
    
    subscript(fieldID id: Element.Field.ID) -> Element? {
        
        get { firstIndex(matching: id).map { self[$0] } }
        
        set {
            guard let index = firstIndex(matching: id)
            else {
                if let newValue { append(newValue) }
                return
            }
            
            if let newValue {
                if case let .field(field) = newValue, field.id == id {
                    self[index] = newValue
                } else {
                    append(newValue)
                }
            } else {
                remove(at: index)
            }
        }
    }
    
    func firstIndex(
        matching id: AnywayPayment.Element.Field.ID
    ) -> Self.Index? {
        
        firstIndex {
            
            guard let fieldID = $0.fieldID else { return false }
            
            return fieldID == id
        }
    }
}

private extension Array where Element == AnywayPayment.Element {
    
    mutating func updatePrimaryFields(
        from updateFields: [AnywayPaymentUpdate.Field]
    ) {
        let updateFields = Dictionary(
            uniqueKeysWithValues: updateFields.map { ($0.name, $0) }
        )
        
        self = map {
            
            guard let id = $0.stringID,
                  let matching = updateFields[id.rawValue]
            else { return $0 }
            
            switch $0 {
            case let .field(field):
                return .field(field.updating(with: matching))
                
            case let .parameter(parameter):
                return .parameter(parameter.updating(with: matching))
            }
        }
    }
    
    mutating func appendComplementaryFields(
        from updateFields: [AnywayPaymentUpdate.Field]
    ) {
        let existingIDs = stringIDs.map(\.rawValue)
        let complimentary: [Element] = updateFields
            .filter { !existingIDs.contains($0.name) }
            .map(Element.Field.init)
            .map(Element.field)
        
        self.append(contentsOf: complimentary)
    }
    
    private var stringIDs: [Element.StringID] {
        
        compactMap(\.stringID)
    }
    
    mutating func appendParameters(
        from updateParameters: [AnywayPaymentUpdate.Parameter],
        with outline: AnywayPayment.Outline
    ) {
        let parameters = updateParameters.map {
            
            AnywayPayment.Element.Parameter(
                parameter: $0,
                fallbackValue: outline[.init($0.field.id)]
            )
        }
        append(contentsOf: parameters.map(Element.parameter))
    }
}

// MARK: - Adapters

private extension AnywayPayment.Element.Field {
    
    init(_ field: AnywayPaymentUpdate.Field) {
        
        self.init(
            id: .string(.init(field.name)),
            value: .init(field.value),
            title: field.title
        )
    }
}

private extension AnywayPayment.Element.Parameter {
    
    init(
        parameter: AnywayPaymentUpdate.Parameter,
        fallbackValue: AnywayPayment.Element.Value?
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
        fallbackValue: AnywayPayment.Element.Value?
    ) {
        self.init(
            id: .init(field.id),
            value: field.content.map { .init($0) } ?? fallbackValue
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
            
        case let .pairs(pairs):
            self = .pairs(pairs.map(Pair.init))
        }
    }
}

private extension AnywayPayment.Element.Parameter.UIAttributes.DataType.Pair {
    
    init(_ pairs: AnywayPaymentUpdate.Parameter.UIAttributes.DataType.Pair) {
        
        self.init(key: pairs.key, value: pairs.value)
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
