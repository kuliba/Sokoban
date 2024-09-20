//
//  AnywayElement.Parameter.swift
//
//
//  Created by Igor Malyarov on 08.06.2024.
//

extension AnywayElement {
    
    public struct Parameter: Equatable {
        
        public let field: Field
        public let icon: Icon?
        public let masking: Masking
        public let validation: Validation
        public let uiAttributes: UIAttributes
        
        public init(
            field: Field,
            icon: Icon?,
            masking: Masking,
            validation: Validation,
            uiAttributes: UIAttributes
        ) {
            self.field = field
            self.icon = icon
            self.masking = masking
            self.validation = validation
            self.uiAttributes = uiAttributes
        }
    }
}

extension AnywayElement.Parameter {
    
    public struct Field: Identifiable, Equatable {
        
        public let id: ID
        public let value: Value?
        
        public init(
            id: ID,
            value: Value?
        ) {
            self.id = id
            self.value = value
        }
        
        public typealias ID = String
        public typealias Value = String
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
            self.title = title
            self.type = type
            self.viewType = viewType
        }
    }
}

extension AnywayElement.Parameter.UIAttributes {
    
    public enum DataType: Equatable {
        
        case _backendReserved
        case number
        case pairs(Pair?, [Pair])
        case string
        
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
        
        case input, maskList, missing, select
    }
    
    public enum InputFieldType: Equatable {
        
        case account
        case address
        case amount
        case bank
        case bic
        case counter
        case date
        case inn
        case insurance
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
