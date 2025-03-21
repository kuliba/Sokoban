//
//  LogicTests.swift
//
//
//  Created by Igor Malyarov on 21.03.2025.
//

import XCTest

class LogicTests: XCTestCase {
    
    typealias Event = CreditCardMVPCoreTests.Event<ApplicationSuccess>
    
    struct ApplicationSuccess: Equatable {
        
        let value: String
    }
    
    func makeApplicationSuccess(
        _ value: String = anyMessage()
    ) -> ApplicationSuccess {
        
        return .init(value: value)
    }
    
    struct ApplicationPayload: Equatable, VerificationCodeProviding {
        
        let value: String
        
        var verificationCode: String { value }
    }
    
    func makePayload(
        _ value: String = anyMessage()
    ) -> ApplicationPayload {
        
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
