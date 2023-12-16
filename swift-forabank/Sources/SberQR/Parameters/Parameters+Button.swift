//
//  Parameters+Button.swift
//
//
//  Created by Igor Malyarov on 16.12.2023.
//

public extension Parameters {
    
    struct Button<Action, ID> {
        
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
}

extension Parameters.Button: Equatable where Action: Equatable, ID: Equatable {}

#warning("move to a namespace")
public enum GetSberQRDataButtonID: String, Equatable {
    
    case buttonPay = "button_pay"
}

#warning("move to a namespace")
public enum GetSberQRDataButtonAction: Equatable {
    
    case pay
}
