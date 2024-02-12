//
//  OTPInputState.swift
//
//
//  Created by Igor Malyarov on 21.01.2024.
//

import Tagged

#warning("maybe add OTP length (used in Digits) - or it would be better to hold those in reducer")
public struct OTPInputState: Equatable {
    
    public let phoneNumber: PhoneNumber
    public var status: Status
    
    public init(
        phoneNumber: PhoneNumber,
        status: Status
    ) {
        self.phoneNumber = phoneNumber
        self.status = status
    }
}

public extension OTPInputState {
    
    typealias PhoneNumber = Tagged<_PhoneNumber, String>
    enum _PhoneNumber {}
    
    enum Status: Equatable {

        case failure(ServiceFailure)
        case input(Input)
        case validOTP
#warning("idea for better - more readable model:")
        /*
         enum OTPInputState: Equatable {
         
         case input(Input)
         case result(ServiceFailure?)
         }
         */
    }
}

public extension OTPInputState.Status {
    
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
