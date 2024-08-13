//
//  AnywayElementModel+Receiver.swift
//  ForaBank
//
//  Created by Igor Malyarov on 26.06.2024.
//

import AnywayPaymentUI
import OTPInputComponent

extension AnywayElementModel: Receiver {
    
    func receive(_ message: AnywayMessage) {
        
        switch (self, message) {
        case let (.widget(.otp(otp)), .otpWarning(warning)):
            otp.event(.otpField(.failure(.serverError(warning))))
            
        case let (.parameter(parameter), .updateValueTo(value)):
            switch parameter.type {
            case let .numberInput(node):
                node.model.event(.textField(.setTextTo(value)))
                
            case let .textInput(node):
                node.model.event(.textField(.setTextTo(value)))
                
            default:
                break
            }
            
        default:
            break
        }
    }
}
