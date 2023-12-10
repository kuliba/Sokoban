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
