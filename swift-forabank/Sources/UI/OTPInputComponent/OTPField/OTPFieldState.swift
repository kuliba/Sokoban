//
//  OTPFieldState.swift
//
//
//  Created by Igor Malyarov on 19.01.2024.
//

public struct OTPFieldState: Equatable {
    
    public var text: String
    public var isInputComplete: Bool
    public var status: Status?
    
    public init(
        text: String = "",
        isInputComplete: Bool = false,
        status: Status? = nil
    ) {
        self.text = text
        self.isInputComplete = isInputComplete
        self.status = status
    }
}

public extension OTPFieldState {
    
    enum Status: Equatable {
        
        case failure(ServiceFailure)
        case inflight
        case validOTP
    }
}
