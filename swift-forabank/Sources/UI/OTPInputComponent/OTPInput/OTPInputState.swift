//
//  OTPInputState.swift
//
//
//  Created by Igor Malyarov on 19.01.2024.
//

public struct OTPInputState: Equatable {
    
    public var text: String
    public var isInputComplete: Bool
    
    public init(
        text: String,
        isOTPComplete: Bool
    ) {
        self.text = text
        self.isInputComplete = isOTPComplete
    }
}
