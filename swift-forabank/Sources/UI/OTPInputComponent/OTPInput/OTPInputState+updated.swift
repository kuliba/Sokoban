//
//  OTPInputState+updated.swift
//  
//
//  Created by Igor Malyarov on 21.01.2024.
//

public extension OTPInputState {
    
    func updated(
        text: String? = nil,
        isInputComplete: Bool? = nil,
        status: Status?? = nil
    ) -> Self {
        
        .init(
            text: text ?? self.text,
            isInputComplete: isInputComplete ?? self.isInputComplete,
            status: status ?? self.status
        )
    }
}
