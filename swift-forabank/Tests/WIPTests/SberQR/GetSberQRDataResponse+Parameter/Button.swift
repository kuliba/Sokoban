//
//  Button.swift
//
//
//  Created by Igor Malyarov on 03.12.2023.
//

extension GetSberQRDataResponse.Parameter {

    struct Button: Equatable {
        
        let id: String
        let value: String
        let color: Color
        let action: Action
        let placement: Placement
        
        enum Color: Equatable {
            
            case red
        }
        
        enum Action: Equatable {
            
            case pay
        }
        
        enum Placement: Equatable {
            
            case bottom
        }
    }
}
