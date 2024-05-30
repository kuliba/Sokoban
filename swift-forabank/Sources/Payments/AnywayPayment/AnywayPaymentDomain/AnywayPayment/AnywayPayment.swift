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
    public var infoMessage: String?
    public let isFinalStep: Bool
    public let isFraudSuspected: Bool
    public let puref: Puref
    
    public init(
        elements: [Element],
        infoMessage: String?,
        isFinalStep: Bool,
        isFraudSuspected: Bool,
        puref: Puref
    ) {
        self.elements = elements
        self.infoMessage = infoMessage
        self.isFinalStep = isFinalStep
        self.isFraudSuspected = isFraudSuspected
        self.puref = puref
    }
}

extension AnywayPayment {
    
    public enum Element: Equatable {
        
        case field(Field)
        case parameter(Parameter)
        case widget(Widget)
    }
    
    public typealias Puref = Tagged<_Puref, String>
    public enum _Puref {}
    
    public enum Status: Equatable {
        
        case infoMessage(String)
    }
}

extension AnywayPayment.Element {
    
    public struct Field: Identifiable, Equatable {
        
        public let id: ID
        public let title: String
        public let value: Value
        public let image: Image?
        
        public init(
            id: ID,
            title: String,
            value: Value,
            image: Image?
        ) {
            self.id = id
            self.title = title
            self.value = value
            self.image = image
        }
    }
    
    public enum Image: Equatable {
        
        case md5Hash(String)
        case svg(String)
        case withFallback(md5Hash: String, svg: String)
    }
    
    public struct Parameter: Equatable {
        
        public let field: Field
        public let image: Image?
        public let masking: Masking
        public let validation: Validation
        public let uiAttributes: UIAttributes
        
        public init(
            field: Field,
            image: Image?,
            masking: Masking,
            validation: Validation,
            uiAttributes: UIAttributes
        ) {
            self.field = field
            self.image = image
           self.masking = masking
            self.validation = validation
            self.uiAttributes = uiAttributes
        }
    }
    
    public enum Widget: Equatable {
        
        case core(PaymentCore)
        case otp(Int?)
    }
}

extension AnywayPayment.Element.Field {
    
    public typealias ID = Tagged<_ID, String>
    public enum _ID {}
    
    public typealias Value = Tagged<_Value, String>
    public enum _Value {}
    
}

extension AnywayPayment.Element.Parameter {
    
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

extension AnywayPayment.Element.Parameter.Field {
    
    public typealias ID = Tagged<_ID, String>
    public enum _ID {}
    
    public typealias Value = Tagged<_Value, String>
    public enum _Value {}
}

extension AnywayPayment.Element.Parameter.UIAttributes {
    
    public enum DataType: Equatable {
        
        case _backendReserved
        case number
        case pairs(Pair, [Pair])
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

extension AnywayPayment.Element.Widget {
    
    public var id: ID {
        
        switch self {
        case .core: return .core
        case .otp:    return .otp
        }
    }
    
    public enum ID {
        
        case core, otp
    }
    
    public struct PaymentCore: Equatable {
        
        public let amount: Decimal
        public let currency: Currency
        public let productID: ProductID
        
        public init(
            amount: Decimal,
            currency: Currency,
            productID: ProductID
        ) {
            self.amount = amount
            self.currency = currency
            self.productID = productID
        }
    }
}

extension AnywayPayment.Element.Widget.PaymentCore {
    
    public typealias Currency = Tagged<_Currency, String>
    public enum _Currency {}
    
    public enum ProductID: Equatable {
        
        case accountID(AccountID)
        case cardID(CardID)
    }
}

extension AnywayPayment.Element.Widget.PaymentCore.ProductID {
    
    public typealias AccountID = Tagged<_AccountID, Int>
    public enum _AccountID {}
    
    public typealias CardID = Tagged<_CardID, Int>
    public enum _CardID {}
}
