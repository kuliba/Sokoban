//
//  OTPInputState.swift
//
//
//  Created by Igor Malyarov on 21.01.2024.
//

#warning("remake as struct, add `phoneNumber: Tagged<String>` field + maybe OTP length (used in Digits) - or it would be better to hold those in reducer")
public enum OTPInputState: Equatable {
    #warning("decouple from OTPFieldFailure? or vice versa up countdown state failure to common failure")
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

public extension OTPInputState {
    
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
    
    typealias OTPResult = Result<OK, ServiceFailure>
    
    struct OK: Equatable {}
}
