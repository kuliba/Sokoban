//
//  OTPFieldState+updated.swift
//
//
//  Created by Igor Malyarov on 21.01.2024.
//

public extension OTPFieldState {
    
    func updated(
        text: String,
        isInputComplete: Bool,
        status: Status?
    ) -> Self {
        
        return .init(
            text: text,
            isInputComplete: isInputComplete,
            status: status
        )
    }
}
