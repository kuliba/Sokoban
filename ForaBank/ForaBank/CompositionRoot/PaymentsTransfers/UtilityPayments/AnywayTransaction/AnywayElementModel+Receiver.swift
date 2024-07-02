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
            
        default:
#warning("FIX ME")
        }
    }
}
