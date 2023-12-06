//
//  Amount.swift
//
//
//  Created by Igor Malyarov on 03.12.2023.
//

extension GetSberQRDataResponse.Parameter {
    
    struct Amount: Equatable {
        
        let id: ID
        let value: String?
        let title: String
        let validationRules: [ValidationRule]
        let button: Button
        
        enum ID: String, Equatable {
            
            case paymentAmount = "payment_amount"
        }
        
        struct Button: Equatable {
            
            let title: String
            let action: Action
            let color: Color
        }
        
        enum Action: Equatable {
            
            case paySberQR
        }
        
        enum Color: Equatable {
            
            case red
        }
        
        struct ValidationRule: Equatable {}
    }
}
