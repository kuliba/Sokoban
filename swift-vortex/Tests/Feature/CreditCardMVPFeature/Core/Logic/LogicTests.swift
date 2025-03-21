//
//  LogicTests.swift
//
//
//  Created by Igor Malyarov on 21.03.2025.
//

import XCTest

class LogicTests: XCTestCase {
    
    typealias State = CreditCardMVPCoreTests.State<ApplicationSuccess, OTP>
    typealias Event = CreditCardMVPCoreTests.Event<ApplicationSuccess>
    typealias Effect = CreditCardMVPCoreTests.Effect<ConfirmApplicationPayload, OTP>
    
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
    
    struct OTP: Equatable {
        
        let value: String
    }
    
    func makeOTP(
        _ value: String = anyMessage()
    ) -> OTP {
        
        return .init(value: value)
    }
    
    func makeApplicationResultFailure(
        message: String = anyMessage(),
        type: Event.FailureType
    ) -> Event {
        
        return .applicationResult(.failure(.init(
            message: message,
            type: type
        )))
    }
    
    func makeApplicationResultSuccess(
        success: ApplicationSuccess? = nil
    ) -> Event {
        
        return .applicationResult(.success(success ?? makeApplicationSuccess()))
    }
}
