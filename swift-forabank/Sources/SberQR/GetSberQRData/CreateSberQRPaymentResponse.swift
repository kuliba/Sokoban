//
//  CreateSberQRPaymentResponse.swift
//
//
//  Created by Igor Malyarov on 10.12.2023.
//

import Foundation
import Tagged

public struct CreateSberQRPaymentResponse: Equatable {
    
    public let parameters: [Parameter]
    
    public init(parameters: [Parameter]) {
     
        self.parameters = parameters
    }
}

public extension CreateSberQRPaymentResponse {
    
    enum Parameter: Equatable {
        
        case button(Button)
        case dataString(DataString)
        case dataLong(DataLong)
        case successStatusIcon(SuccessStatusIcon)
        case successText(SuccessText)
        case subscriber(Subscriber)
        case successOptionButton(SuccessOptionButton)
    }
}
 
public extension CreateSberQRPaymentResponse.Parameter {
    
    struct Button: Equatable {
        
        let id: ID
        let value: String
        let color: Color
        let action: Action
        let placement: Placement
        
        public init(
            id: ID,
            value: String,
            color: Color,
            action: Action,
            placement: Placement
        ) {
            self.id = id
            self.value = value
            self.color = color
            self.action = action
            self.placement = placement
        }
    }
    
    struct DataLong: Equatable {
        
        let id: ID
        let value: Int
        
        public init(id: ID, value: Int) {

            self.id = id
            self.value = value
        }
    }
    
    struct DataString: Equatable {
        
        let id: ID
        let value: String
        
        public init(id: ID, value: String) {
         
            self.id = id
            self.value = value
        }
    }
    
    struct SuccessStatusIcon: Equatable {
        
        let id: ID
        let value: StatusIcon
        
        public init(id: ID, value: StatusIcon) {
            
            self.id = id
            self.value = value
        }
        
        public enum StatusIcon: Equatable {
            
            case complete
        }
    }
    
    struct SuccessText: Equatable {
        
        let id: ID
        let value: String
        let style: Style
        
        public init(id: ID, value: String, style: Style) {
         
            self.id = id
            self.value = value
            self.style = style
        }
    }
    
    struct Subscriber: Equatable {
        
        let id: ID
        let value: String
        let style: Style
        let icon: String
        let subscriptionPurpose: SubscriptionPurpose?
        
        public init(
            id: ID, 
            value: String,
            style: Style,
            icon: String,
            subscriptionPurpose: SubscriptionPurpose?
        ) {
            self.id = id
            self.value = value
            self.style = style
            self.icon = icon
            self.subscriptionPurpose = subscriptionPurpose
        }
        
        public struct SubscriptionPurpose: Equatable {}
    }
    
    struct SuccessOptionButton: Equatable {
        
        let id: ID
        let values: [Value]
        
        public init(id: ID, values: [Value]) {
         
            self.id = id
            self.values = values
        }
        
        public enum Value: Equatable {
            
            case details, document
        }
    }
    
    // MARK: - Common Types
    
    enum Action: Equatable {
        
        case main
    }
    
    enum Color: Equatable {
        
        case red
    }
    
    enum ID: Equatable {
        
        case paymentOperationDetailId
        case printFormType
        case successStatus
        case successTitle
        case successAmount
        case brandName
        case successOptionButtons
        case buttonMain
    }
    
    enum Placement: Equatable {
        
        case bottom
    }
    
    enum Style: Equatable {
        
        case amount
        case title
        case small
    }
}
