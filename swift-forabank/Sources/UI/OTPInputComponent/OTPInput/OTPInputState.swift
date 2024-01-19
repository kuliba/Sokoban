//
//  OTPInputState.swift
//
//
//  Created by Igor Malyarov on 19.01.2024.
//

public struct OTPInputState: Equatable {
    
    public var text: String
    public var isInputComplete: Bool
    public var status: Status?
    
    public init(
        text: String,
        isInputComplete: Bool,
        status: Status? = nil
    ) {
        self.text = text
        self.isInputComplete = isInputComplete
        self.status = status
    }
}

public extension OTPInputState {
    
    enum Status: Equatable {
        
        case failure(OTPInputFailure)
        case inflight
    }
}

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
