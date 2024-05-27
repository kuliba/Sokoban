//
//  CodeInputState.swift
//
//
//  Created by Дмитрий Савушкин on 24.05.2024.
//

import Foundation
import Tagged

public struct CodeInputState: Equatable {
    
    public var status: Status
    
    public init(
        status: Status
    ) {
        self.status = status
    }
}

public extension CodeInputState {
    
    enum Status: Equatable {

        case failure(ServiceFailure)
        case input(Input)
        case validOTP
    }
}

public extension CodeInputState.Status {
    
    struct Input: Equatable {
        
        public var countdown: CountdownState
        public var otpField: OTPFieldState
        
        public init(
            countdown: CountdownState,
            otpField: OTPFieldState
        ) {
            self.countdown = countdown
            self.otpField = otpField
        }
    }
}
