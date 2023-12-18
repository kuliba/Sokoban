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
        case successOptionButton(SuccessOptionButtons)
    }
}

public extension CreateSberQRPaymentResponse.Parameter {
    
    typealias Button = Parameters.Button<Action, CreateSberQRPaymentIDs.ButtonID>
    typealias DataString = Parameters.DataString<CreateSberQRPaymentIDs.DataStringID>
    typealias DataLong = Parameters.DataLong
    typealias Subscriber = Parameters.Subscriber
    typealias SuccessOptionButtons = Parameters.SuccessOptionButtons
    typealias SuccessStatusIcon = Parameters.SuccessStatusIcon
    typealias SuccessText = Parameters.SuccessText
}

public extension CreateSberQRPaymentResponse.Parameter {
    
    enum Action: Equatable {
        
        case main
    }
}
