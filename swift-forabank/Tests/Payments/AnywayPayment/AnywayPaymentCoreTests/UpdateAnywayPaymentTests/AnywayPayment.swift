//
//  AnywayPayment.swift
//
//
//  Created by Igor Malyarov on 06.04.2024.
//

import Foundation

struct AnywayPayment: Equatable {
    
    var elements: [Element]
    let hasAmount: Bool
    let isFinalStep: Bool
    let isFraudSuspected: Bool
    var status: Status?
}

extension AnywayPayment {
    
    enum Element: Equatable {
        
        case field(Field)
        case parameter(Parameter)
    }
    
    enum Status: Equatable {
        
        case infoMessage(String)
    }
}

extension AnywayPayment.Element {
    
    struct Field: Identifiable, Equatable {
        
        let id: ID
        let value: String
        let title: String
    }
    
    struct Parameter: Equatable {
        
        let field: Field
        let masking: Masking
        let validation: Validation
        let uiAttributes: UIAttributes
    }
}

extension AnywayPayment.Element.Field {
    
    enum ID: Hashable {
        
        case otp
        case string(String)
    }
}

extension AnywayPayment.Element.Parameter {
    
    struct Field: Identifiable, Equatable {
        
        let id: String
        let value: String?
    }
    
    struct Masking: Equatable {
        
        let inputMask: String?
        let mask: String?
    }
    
    struct Validation: Equatable {
        
        let isRequired: Bool
        let maxLength: Int?
        let minLength: Int?
        let regExp: String
    }
    
    struct UIAttributes: Equatable {
        
        let dataType: DataType // not used for `viewType: ViewType = .input` https://shorturl.at/hnrE1
        let group: String?
        let isPrint: Bool // not used for `type: FieldType = .input`
        let phoneBook: Bool
        let isReadOnly: Bool
        let subGroup: String?
        let subTitle: String?
        let svgImage: String?
        let title: String
        let type: FieldType
        let viewType: ViewType
    }
}

extension AnywayPayment.Element.Parameter.UIAttributes {
    
    enum DataType: Equatable {
        
        case string
        case pairs([Pair])
        
        struct Pair: Equatable {
            
            let key: String
            let value: String
        }
    }
    
    enum FieldType: Equatable {
        
        case input, select, maskList
    }
    
    enum InputFieldType: Equatable {
        
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
    
    enum ViewType: Equatable {
        
        case constant, input, output
    }
}
