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
    
    func test_getPINConfirmationCode_shouldDeliverErrorOnAuthenticateActivationFailure() {
        
        let (sut, authenticateSpy, _, _, _, _) = makeSUT()
        
        expect(sut, toDeliver: [.failure(.activationFailure)], on: {
            
            authenticateSpy.complete(with: .failure(.activationFailure))
        })
    }
    
    func test_getPINConfirmationCode_shouldDeliverErrorOnAuthenticateAuthenticationFailure() {
        
        let (sut, authenticateSpy, _, _, _, _) = makeSUT()
        
        expect(sut, toDeliver: [.failure(.authenticationFailure)], on: {
            
            authenticateSpy.complete(with: .failure(.authenticationFailure))
        })
    }
    
    func test_getPINConfirmationCode_shouldDeliverErrorOnConfirmProcessInvalidFailure() {
        
        let statusCode = 500
        let invalidData = anyData()
        let (sut, authenticateSpy, _, confirmProcessSpy, _, _) = makeSUT()
        
        expect(sut, toDeliver: [
            .failure(.invalid(statusCode: statusCode, data: invalidData))
        ], on: {
            authenticateSpy.complete(with: anySuccess())
            confirmProcessSpy.complete(with: .failure(.invalid(statusCode: statusCode, data: invalidData)))
        })
    }
    
    func test_getPINConfirmationCode_shouldDeliverErrorOnConfirmProcessNetworkFailure() {
        
        let (sut, authenticateSpy, _, confirmProcessSpy, _, _) = makeSUT()
        
        expect(sut, toDeliver: [.failure(.network)], on: {
            
            authenticateSpy.complete(with: anySuccess())
            confirmProcessSpy.complete(with: .failure(.network))
        })
    }
    
    func test_getPINConfirmationCode_shouldDeliverErrorOnConfirmProcessServerFailure() {
        
        let statusCode = 500
        let errorMessage = "Confirmation Error"
        let (sut, authenticateSpy, _, confirmProcessSpy, _, _) = makeSUT()
        
        expect(sut, toDeliver: [
            .failure(.server(statusCode: statusCode, errorMessage: errorMessage))
        ], on: {
            authenticateSpy.complete(with: anySuccess())
            confirmProcessSpy.complete(with: .failure(.server(statusCode: statusCode, errorMessage: errorMessage)))
        })
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
    
    private func expect(
        _ sut: SUT,
        toDeliver expectedResults: [SUT.GetPINConfirmationCodeResult],
        on action: @escaping () -> Void,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        var receivedResults = [SUT.GetPINConfirmationCodeResult]()
        let exp = expectation(description: "wait for completion")
        
        sut.getPINConfirmationCode {
            
            receivedResults.append($0)
            exp.fulfill()
        }
        
        action()
        
        wait(for: [exp], timeout: 1.0)
        
        assert(
            receivedResults.mapToEquatable(),
            equals: expectedResults.mapToEquatable(),
            file: file, line: line
        )
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

private extension Array where Element == ChangePINService.GetPINConfirmationCodeResult {
    
    func mapToEquatable() -> [ChangePINService.GetPINConfirmationCodeResult.EquatableGetPINConfirmationCodeResult] {
        
        map { $0.mapToEquatable() }
    }
}

private extension ChangePINService.GetPINConfirmationCodeResult {
    
    func mapToEquatable() -> EquatableGetPINConfirmationCodeResult {
        
        self
            .map { EquatableConfirmResponse(response: $0) }
            .mapError(EquatableError.init)
    }
    
    typealias EquatableGetPINConfirmationCodeResult = Swift.Result<EquatableConfirmResponse, EquatableError>
    
    struct EquatableConfirmResponse: Equatable {
        
        let otpEventID: String
        let phone: String
        
        init(response: ChangePINService.ConfirmResponse) {
            
            self.otpEventID = response.otpEventID.eventIDValue
            self.phone = response.phone
        }
    }
    
    enum EquatableError: Error & Equatable {
        
        case activationFailure
        case authenticationFailure
        case invalid(statusCode: Int, data: Data)
        case network
        case retry(statusCode: Int, errorMessage: String, retryAttempts: Int)
        case server(statusCode: Int, errorMessage: String)
        case serviceError(ServiceError)
        
        init(error: ChangePINService.Error) {
            
            switch error {
            case .activationFailure:
                self = .activationFailure
                
            case .authenticationFailure:
                self = .authenticationFailure
                
            case let .invalid(statusCode: statusCode, data: data):
                self = .invalid(statusCode: statusCode, data: data)
            
            case .network:
                self = .network
                
            case let .retry(statusCode: statusCode, errorMessage: errorMessage, retryAttempts: retryAttempts):
                self = .retry(statusCode: statusCode, errorMessage: errorMessage, retryAttempts: retryAttempts)
                
            case let .server(statusCode: statusCode, errorMessage: errorMessage):
                self = .server(statusCode: statusCode, errorMessage: errorMessage)
                
            case let .serviceError(serviceError):
                switch serviceError {
                case .checkSessionFailure:
                    self = .serviceError(.checkSessionFailure)
                    
                case .decryptionFailure:
                    self = .serviceError(.decryptionFailure)
                    
                case .makeJSONFailure:
                    self = .serviceError(.makeJSONFailure)
                }
            }
        }
        
        enum ServiceError {
            
            case checkSessionFailure
            case decryptionFailure
            case makeJSONFailure
        }
    }
}

private func anySuccess(
    sessionIDValue: String = UUID().uuidString
) -> ChangePINService.AuthenticateResult {
    
    .success(.init(sessionIDValue: sessionIDValue))
}
