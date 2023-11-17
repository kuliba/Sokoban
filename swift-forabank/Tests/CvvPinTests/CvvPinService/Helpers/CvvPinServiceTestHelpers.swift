//
//  CvvPinServiceTestHelpers.swift
//  
//
//  Created by Igor Malyarov on 22.08.2023.
//

import CvvPin
import XCTest

class CvvPinServiceTestHelpers: XCTestCase {
    
    func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: CvvPinService,
        sessionCodeSpy: SessionCodeLoaderSpy,
        keyExchangeSpy: KeyExchangeServiceSpy,
        transferKeySpy: TransferKeySpy
    ) {
        let sessionCodeSpy = SessionCodeLoaderSpy()
        let keyExchangeSpy = KeyExchangeServiceSpy()
        let transferKeySpy = TransferKeySpy()
        let sut = CvvPinService(
            getProcessingSessionCode: sessionCodeSpy.load,
            exchangeKey: keyExchangeSpy.exchangeKey,
            transferPublicKey: transferKeySpy.bind
        )
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(sessionCodeSpy, file: file, line: line)
        trackForMemoryLeaks(keyExchangeSpy, file: file, line: line)
        trackForMemoryLeaks(transferKeySpy, file: file, line: line)
        
        return (sut, sessionCodeSpy, keyExchangeSpy, transferKeySpy)
    }
    
    final class SessionCodeLoaderSpy: SessionCodeLoader {
        
        func load(completion: @escaping LoadCompletion) {
            
            messages.append(.load)
            completions.append(completion)
        }
        
        private(set) var messages = [Message]()
        private var completions = [LoadCompletion]()
        
        func complete(
            with result: SessionCodeLoader.Result,
            at index: Int = 0
        ) {
            completions[index](result)
        }
        
        enum Message: Equatable {
            
            case load
        }
    }
    
    final class KeyExchangeServiceSpy {
        
        typealias Result = KeyExchangeDomain.Result
        typealias Completion = KeyExchangeDomain.Completion
        typealias SessionCode = KeyExchangeDomain.SessionCode
        
        func exchangeKey(
            with sessionCode: SessionCode,
            completion: @escaping Completion
        ) {
            messages.append(.exchangeKey)
            completions.append(completion)
        }
        
        private(set) var messages = [Message]()
        private var completions = [Completion]()
        
        func complete(
            with result: Result,
            at index: Int = 0
        ) {
            completions[index](result)
        }
        
        enum Message: Equatable {
            
            case exchangeKey
        }
    }
    
    final class TransferKeySpy {
        
        typealias Result = TransferPublicKeyDomain.Result
        typealias Completion = TransferPublicKeyDomain.Completion
        typealias OTP = TransferPublicKeyDomain.OTP
        typealias EventID = TransferPublicKeyDomain.EventID
        typealias SharedSecret = TransferPublicKeyDomain.SharedSecret
        
        func bind(
            _ otp: OTP,
            _ eventID: EventID,
            _ secret: SharedSecret,
            completion: @escaping Completion
        ) {
            messages.append(.bind)
            completions.append(completion)
        }
        
        private(set) var messages = [Message]()
        private var completions = [Completion]()
        
        func complete(with result: Result, at index: Int = 0) {
            
            completions[index](result)
        }
        
        enum Message: Equatable {
            
            case bind
        }
    }
    
    func uniqueOTP() -> TransferPublicKeyDomain.OTP {
        
        .init(value: UUID().uuidString)
    }
}
