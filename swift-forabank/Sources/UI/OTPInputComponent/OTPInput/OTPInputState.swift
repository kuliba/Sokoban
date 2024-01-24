//
//  OTPInputState.swift
//
//
//  Created by Igor Malyarov on 21.01.2024.
//

#warning("remake as struct, add `phoneNumber: Tagged<String>` field + maybe OTP length (used in Digits)")
public enum OTPInputState: Equatable {
    #warning("decouple from OTPFieldFailure? or vice versa up countduwn state failure to common failure")
    case failure(OTPFieldFailure)
    case input(Input)
    case validOTP
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
    
    typealias OTPResult = Result<OK, OTPFieldFailure>
    
    struct OK: Equatable {}
}
