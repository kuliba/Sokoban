//
//  ChangePINServiceTests.swift
//  
//
//  Created by Igor Malyarov on 04.11.2023.
//

import CVVPIN_Services
import XCTest

final class ChangePINServiceTests: XCTestCase {
    
    func test_init_shouldNotCallCollaborators() {
        
        let (_, authenticateSpy, publicRSAKeyDecryptSpy, confirmProcessSpy, makePINChangeJSONSpy, changePINProcessSpy) = makeSUT()
        
        XCTAssertNoDiff(authenticateSpy.callCount, 0)
        XCTAssertNoDiff(publicRSAKeyDecryptSpy.callCount, 0)
        XCTAssertNoDiff(confirmProcessSpy.callCount, 0)
        XCTAssertNoDiff(makePINChangeJSONSpy.callCount, 0)
        XCTAssertNoDiff(changePINProcessSpy.callCount, 0)
    }
    
    // MARK: - Helpers
    
    private typealias SUT = ChangePINService
    
    private func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        authenticateSpy: AuthenticateSpy,
        publicRSAKeyDecryptSpy: PublicRSAKeyDecryptSpy,
        confirmProcessSpy: ConfirmProcessSpy,
        makePINChangeJSONSpy: MakePINChangeJSONSpy,
        changePINProcessSpy: ChangePINProcessSpy
    ) {
        let authenticateSpy = AuthenticateSpy()
        let publicRSAKeyDecryptSpy = PublicRSAKeyDecryptSpy()
        let confirmProcessSpy = ConfirmProcessSpy()
        let makePINChangeJSONSpy = MakePINChangeJSONSpy()
        let changePINProcessSpy = ChangePINProcessSpy()
        let sut = SUT(
            authenticate: authenticateSpy.authenticate(completion:),
            publicRSAKeyDecrypt: publicRSAKeyDecryptSpy.decrypt(_:completion:),
            confirmProcess: confirmProcessSpy.process(_:completion:),
            makePINChangeJSON: makePINChangeJSONSpy.make(cardID:pin:otp:completion:),
            changePINProcess: changePINProcessSpy.process(_:completion:)
        )
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(authenticateSpy, file: file, line: line)
        trackForMemoryLeaks(publicRSAKeyDecryptSpy, file: file, line: line)
        trackForMemoryLeaks(confirmProcessSpy, file: file, line: line)
        trackForMemoryLeaks(makePINChangeJSONSpy, file: file, line: line)
        trackForMemoryLeaks(changePINProcessSpy, file: file, line: line)
        
        return (sut, authenticateSpy, publicRSAKeyDecryptSpy, confirmProcessSpy, makePINChangeJSONSpy, changePINProcessSpy)
    }
    
    private final class AuthenticateSpy {
                
        private(set) var completions = [SUT.AuthenticateCompletion]()
        
        var callCount: Int { completions.count }
        
        func authenticate(
            completion: @escaping SUT.AuthenticateCompletion
        ) {
            completions.append(completion)
        }
        
        func complete(
            with result: SUT.AuthenticateResult,
            at index: Int = 0
        ) {
            completions[index](result)
        }
    }
    
    private final class PublicRSAKeyDecryptSpy {
        
        typealias Message = (payload: String, completion: SUT.PublicRSAKeyDecryptCompletion)
        
        private(set) var messages = [Message]()
        
        var callCount: Int { messages.count }
        
        func decrypt(
            _ payload: String,
            completion: @escaping SUT.PublicRSAKeyDecryptCompletion
        ) {
            messages.append((payload, completion))
        }
        
        func complete(
            with result: SUT.PublicRSAKeyDecryptResult,
            at index: Int = 0
        ) {
            messages[index].completion(result)
        }
    }
    
    private final class ConfirmProcessSpy {
        
        typealias Message = (payload: SUT.SessionID, completion: SUT.ConfirmProcessCompletion)
        
        private(set) var messages = [Message]()
        
        var callCount: Int { messages.count }
        
        func process(
            _ payload: SUT.SessionID,
            completion: @escaping SUT.ConfirmProcessCompletion
        ) {
            messages.append((payload, completion))
        }
        
        func complete(
            with result: SUT.ConfirmProcessResult,
            at index: Int = 0
        ) {
            messages[index].completion(result)
        }
    }
    
    private final class MakePINChangeJSONSpy {
        
        typealias Message = (payload: (SUT.CardID, SUT.PIN, SUT.OTP), completion: SUT.MakePINChangeJSONCompletion)
        
        private(set) var messages = [Message]()
        
        var callCount: Int { messages.count }
        
        func make(
            cardID: SUT.CardID,
            pin: SUT.PIN,
            otp: SUT.OTP,
            completion: @escaping SUT.MakePINChangeJSONCompletion
        ) {
            messages.append(((cardID, pin, otp), completion))
        }
        
        func complete(
            with result: SUT.MakePINChangeJSONResult,
            at index: Int = 0
        ) {
            messages[index].completion(result)
        }
    }
    
    private final class ChangePINProcessSpy {
        
        typealias Message = (payload: (SUT.SessionID, Data), completion: SUT.ChangePINProcessCompletion)
        
        private(set) var messages = [Message]()
        
        var callCount: Int { messages.count }
        
        func process(
            _ payload: (SUT.SessionID, Data),
            completion: @escaping SUT.ChangePINProcessCompletion
        ) {
            messages.append((payload, completion))
        }
        
        func complete(
            with result: SUT.ChangePINProcessResult,
            at index: Int = 0
        ) {
            messages[index].completion(result)
        }
    }
}
