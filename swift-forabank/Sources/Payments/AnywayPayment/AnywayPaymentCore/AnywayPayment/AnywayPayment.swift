//
//  AnywayPayment.swift
//
//
//  Created by Igor Malyarov on 06.04.2024.
//

import Foundation
import Tagged

public struct AnywayPayment: Equatable {
    
    public var elements: [Element]
    public let hasAmount: Bool
    public let isFinalStep: Bool
    public let isFraudSuspected: Bool
    public let snapshot: Snapshot
    public var status: Status?
    
    public init(
        elements: [Element],
        hasAmount: Bool,
        isFinalStep: Bool,
        isFraudSuspected: Bool,
        snapshot: Snapshot,
        status: Status?
    ) {
        self.elements = elements
        self.hasAmount = hasAmount
        self.isFinalStep = isFinalStep
        self.isFraudSuspected = isFraudSuspected
        self.snapshot = snapshot
        self.status = status
    }
}

extension AnywayPayment {
    
    public enum Element: Equatable {
        
        case field(Field)
        case parameter(Parameter)
    }
    
    public typealias Snapshot = [Element.StringID: Element.Value]
    
    public enum Status: Equatable {
        
        case infoMessage(String)
    }
}

extension AnywayPayment.Element {
    
    public struct Field: Identifiable, Equatable {
        
        public let id: ID
        public let value: Value
        public let title: String
        
        public init(
            id: ID, 
            value: Value,
            title: String
        ) {
            self.id = id
            self.value = value
            self.title = title
        }
    }
    
    public typealias StringID = Tagged<_StringID, String>
    public enum _StringID {}
    
    public struct Parameter: Equatable {
        
        public let field: Field
        public let masking: Masking
        public let validation: Validation
        public let uiAttributes: UIAttributes
        
        public init(
            field: Field, 
            masking: Masking,
            validation: Validation,
            uiAttributes: UIAttributes
        ) {
            self.field = field
            self.masking = masking
            self.validation = validation
            self.uiAttributes = uiAttributes
        }
    }
    
    public typealias Value = Tagged<_Value, String>
    public enum _Value {}
}

extension AnywayPayment.Element.Field {
    
    public enum ID: Hashable {
        
        case otp
        case string(AnywayPayment.Element.StringID)
    }
}

extension AnywayPayment.Element.Parameter {
    
    public struct Field: Identifiable, Equatable {
        
        public let id: AnywayPayment.Element.StringID
        public let value: AnywayPayment.Element.Value?
        
        public init(
            id: AnywayPayment.Element.StringID,
            value: AnywayPayment.Element.Value?
        ) {
            self.id = id
            self.value = value
        }
    }
    
    public struct Masking: Equatable {
        
        public let inputMask: String?
        public let mask: String?
        
        public init(
            inputMask: String?,
            mask: String?
        ) {
            self.inputMask = inputMask
            self.mask = mask
        }
    }
    
    public struct Validation: Equatable {
        
        public let isRequired: Bool
        public let maxLength: Int?
        public let minLength: Int?
        public let regExp: String
        
        public init(
            isRequired: Bool, 
            maxLength: Int?,
            minLength: Int?,
            regExp: String
        ) {
            self.isRequired = isRequired
            self.maxLength = maxLength
            self.minLength = minLength
            self.regExp = regExp
        }
    }
    
    public struct UIAttributes: Equatable {
        
        public let dataType: DataType // not used for `viewType: ViewType = .input` https://shorturl.at/hnrE1
        public let group: String?
        public let isPrint: Bool // not used for `type: FieldType = .input`
        public let phoneBook: Bool
        public let isReadOnly: Bool
        public let subGroup: String?
        public let subTitle: String?
        public let svgImage: String?
        public let title: String
        public let type: FieldType
        public let viewType: ViewType
        
        public init(
            dataType: DataType, 
            group: String?,
            isPrint: Bool,
            phoneBook: Bool,
            isReadOnly: Bool,
            subGroup: String?,
            subTitle: String?,
            svgImage: String?,
            title: String,
            type: FieldType,
            viewType: ViewType
        ) {
            self.dataType = dataType
            self.group = group
            self.isPrint = isPrint
            self.phoneBook = phoneBook
            self.isReadOnly = isReadOnly
            self.subGroup = subGroup
            self.subTitle = subTitle
            self.svgImage = svgImage
            self.title = title
            self.type = type
            self.viewType = viewType
        }
    }
}

extension AnywayPayment.Element.Parameter.UIAttributes {
    
    public enum DataType: Equatable {
        
        case string
        case pairs([Pair])
        
        public struct Pair: Equatable {
            
            public let key: String
            public let value: String
            
            public init(
                key: String,
                value: String
            ) {
                self.key = key
                self.value = value
            }
        }
    }
    
    public enum FieldType: Equatable {
        
        case input, select, maskList
    }
    
    public enum InputFieldType: Equatable {
        
        case account
        case address
        case amount
        case bank
        case bic
        case counter
        case date
        case insurance
        case inn
        case name
        case oktmo
        case penalty
        case phone
        case purpose
        case recipient
        case view
    }
    
    public enum ViewType: Equatable {
        
        case constant, input, output
    }
}
