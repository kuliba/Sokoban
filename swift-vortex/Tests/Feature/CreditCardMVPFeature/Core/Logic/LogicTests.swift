//
//  LogicTests.swift
//
//
//  Created by Igor Malyarov on 21.03.2025.
//

import XCTest

class LogicTests: XCTestCase {
    
    struct ApplicationSuccess: Equatable {
        
        let value: String
    }
    
    func makeApplicationSuccess(
        _ value: String = anyMessage()
    ) -> ApplicationSuccess {
        
        return .init(value: value)
    }
    
    struct ConfirmApplicationPayload: Equatable, VerificationCodeProviding {
        
        let value: String
        
        var verificationCode: String { value }
    }
    
    func makePayload(
        _ value: String = anyMessage()
    ) -> ConfirmApplicationPayload {
        
        return .init(value: value)
    }
}
