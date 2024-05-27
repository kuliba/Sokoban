//
//  OTPInputState.swift
//
//
//  Created by Igor Malyarov on 21.01.2024.
//

import Tagged

#warning("maybe add OTP length (used in Digits) - or it would be better to hold those in reducer")
public struct OTPInputState: Equatable {
    
    public let phoneNumber: PhoneNumberMask
    public var status: Status
    
    public init(
        phoneNumber: PhoneNumberMask,
        status: Status
    ) {
        self.phoneNumber = phoneNumber
        self.status = status
    }
}

public extension OTPInputState {
    
    typealias PhoneNumberMask = Tagged<_PhoneNumberMask, String>
    enum _PhoneNumberMask {}
    
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
        
        public init(input: CodeInputState.Status.Input) {
            
            switch input.countdown {
            case .completed:
                self.countdown = .completed
            
            case let .failure(failure):
                self.countdown = .failure(failure)
            
            case let .running(remaining: remaining):
                self.countdown = .running(remaining: remaining)
            
            case let .starting(duration: duration):
                self.countdown = .starting(duration: duration)
            }
            
            self.otpField = input.otpField
        }
    }
}
