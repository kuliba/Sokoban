//
//  CVVPINFunctionalityActivationServiceTests.swift
//  
//
//  Created by Igor Malyarov on 04.11.2023.
//

import CVVPIN_Services
import XCTest

final class CVVPINFunctionalityActivationServiceTests: XCTestCase {
    
    func test_init_shouldNotCallCollaborators() {
        
        let (_, getCodeSpy, formSessionKeySpy, bindKeySpy) = makeSUT()
        
        XCTAssertNoDiff(getCodeSpy.callCount, 0)
        XCTAssertNoDiff(formSessionKeySpy.callCount, 0)
        XCTAssertNoDiff(bindKeySpy.callCount, 0)
    }
    
    // MARK: - activate
    
    func test_activate_shouldDeliverErrorOnGetCodeInvalidFailure() {
        
        let statusCode = 500
        let invalidData = anyData()
        let (sut, getCodeSpy, _, _) = makeSUT()
        
        expectActivate(sut, toDeliver: [
            .failure(.invalid(statusCode: statusCode, data: invalidData))
        ], on: {
            getCodeSpy.complete(with: .failure(.invalid(statusCode: statusCode, data: invalidData)))
        })
    }
    
    func test_activate_shouldDeliverErrorOnGetCodeNetworkFailure() {
        
        let (sut, getCodeSpy, _, _) = makeSUT()
        
        expectActivate(sut, toDeliver: [.failure(.network)], on: {
            
            getCodeSpy.complete(with: .failure(.network))
        })
    }
    
    func test_activate_shouldDeliverErrorOnGetCodeServerFailure() {
        
        let statusCode = 500
        let errorMessage = "Get Code Error"
        let (sut, getCodeSpy, _, _) = makeSUT()
        
        expectActivate(sut, toDeliver: [
            .failure(.server(statusCode: statusCode, errorMessage: errorMessage))
        ], on: {
            getCodeSpy.complete(with: .failure(.server(statusCode: statusCode, errorMessage: errorMessage)))
        })
    }
    
    func test_activate_shouldDeliverErrorOnFormSessionKeyInvalidFailure() {
        
        let statusCode = 500
        let invalidData = anyData()
        let (sut, getCodeSpy, formSessionKeySpy, _) = makeSUT()
        
        expectActivate(sut, toDeliver: [
            .failure(.invalid(statusCode: statusCode, data: invalidData))
        ], on: {
            getCodeSpy.complete(with: anySuccess())
            formSessionKeySpy.complete(with: .failure(.invalid(statusCode: statusCode, data: invalidData)))
        })
    }
    
    func test_activate_shouldDeliverErrorOnFormSessionKeyNetworkFailure() {
        
        let (sut, getCodeSpy, formSessionKeySpy, _) = makeSUT()
        
        expectActivate(sut, toDeliver: [.failure(.network)], on: {
            
            getCodeSpy.complete(with: anySuccess())
            formSessionKeySpy.complete(with: .failure(.network))
        })
    }
    
    func test_activate_shouldDeliverErrorOnFormSessionKeyServerFailure() {
        
        let statusCode = 500
        let errorMessage = "Forn Session Key Error"
        let (sut, getCodeSpy, formSessionKeySpy, _) = makeSUT()
        
        expectActivate(sut, toDeliver: [
            .failure(.server(statusCode: statusCode, errorMessage: errorMessage))
        ], on: {
            getCodeSpy.complete(with: anySuccess())
            formSessionKeySpy.complete(with: .failure(.server(statusCode: statusCode, errorMessage: errorMessage)))
        })
    }
    
    func test_activate_shouldDeliverErrorOnFormSessionKeyServiceFailure() {
        
        let (sut, getCodeSpy, formSessionKeySpy, _) = makeSUT()
        
        expectActivate(sut, toDeliver: [.failure(.serviceFailure)], on: {
            
            getCodeSpy.complete(with: anySuccess())
            formSessionKeySpy.complete(with: .failure(.serviceFailure))
        })
    }
    
    func test_activate_shouldDeliverValueOnSuccess() {
        
        let codeValue = UUID().uuidString
        let phoneValue = UUID().uuidString
        let sessionKeyValue = anyData()
        let eventIDValue = UUID().uuidString
        let sessionTTL = 13
        let (sut, getCodeSpy, formSessionKeySpy, _) = makeSUT()
        
        expectActivate(
            sut,
            toDeliver: [.success(.init(
                code: .init(codeValue: codeValue),
                phone: .init(phoneValue: phoneValue),
                sessionKey: .init(sessionKeyValue: sessionKeyValue),
                eventID: .init(eventIDValue: eventIDValue),
                sessionTTL: sessionTTL
                
            ))],
            on: {
                getCodeSpy.complete(with: .success(.init(
                    code: .init(codeValue: codeValue),
                    phone: .init(phoneValue: phoneValue)
                )))
                formSessionKeySpy.complete(with: .success(.init(
                    sessionKey: .init(sessionKeyValue: sessionKeyValue),
                    eventID: .init(eventIDValue: eventIDValue),
                    sessionTTL: sessionTTL
                )))
            }
        )
    }
    
    func test_activate_shouldNotDeliverGetCodeResultOnInstanceDeallocation() {
        
        var sut: SUT?
        let getCodeSpy: GetCodeSpy
        (sut, getCodeSpy, _, _) = makeSUT()
        var receivedResults = [SUT.ActivateResult]()
        
        sut?.activate { receivedResults.append($0) }
        sut = nil
        getCodeSpy.complete(with: anySuccess())
        
        XCTAssert(receivedResults.isEmpty)
    }
    
    func test_activate_shouldNotDeliverFormSessionKeyResultOnInstanceDeallocation() {
        
        var sut: SUT?
        let getCodeSpy: GetCodeSpy
        let formSessionKeySpy: FormSessionKeySpy
        (sut, getCodeSpy, formSessionKeySpy, _) = makeSUT()
        var receivedResults = [SUT.ActivateResult]()
        
        sut?.activate { receivedResults.append($0) }
        getCodeSpy.complete(with: anySuccess())
        sut = nil
        formSessionKeySpy.complete(with: anySuccess())
        
        XCTAssert(receivedResults.isEmpty)
    }
    
    // MARK: - confirmActivation
    
    func test_confirmActivation_shouldDeliverErrorOnBindKeyInvalidFailure() {
        
        let statusCode = 500
        let invalidData = anyData()
        let (sut, _, _, bindKeySpy) = makeSUT()
        
        expectConfirm(sut, toDeliver: [
            .failure(.invalid(statusCode: statusCode, data: invalidData))
        ], on: {
            bindKeySpy.complete(with: .failure(.invalid(statusCode: statusCode, data: invalidData)))
        })
    }
    
    func test_confirmActivation_shouldDeliverErrorOnBindKeyNetworkFailure() {
        
        let (sut, _, _, bindKeySpy) = makeSUT()
        
        expectConfirm(sut, toDeliver: [.failure(.network)], on: {
            
            bindKeySpy.complete(with: .failure(.network))
        })
    }
    
    func test_confirmActivation_shouldDeliverErrorOnBindKeyRetryFailure() {
        
        let statusCode = 500
        let errorMessage = "Forn Session Key Error"
        let retryAttempts = 4
        let (sut, _, _, bindKeySpy) = makeSUT()
        
        expectConfirm(sut, toDeliver: [
            .failure(.retry(statusCode: statusCode, errorMessage: errorMessage, retryAttempts: retryAttempts))
        ], on: {
            bindKeySpy.complete(with: .failure(.retry(statusCode: statusCode, errorMessage: errorMessage, retryAttempts: retryAttempts)))
        })
    }
    
    func test_confirmActivation_shouldDeliverErrorOnBindKeyServerFailure() {
        
        let statusCode = 500
        let errorMessage = "Forn Session Key Error"
        let (sut, _, _, bindKeySpy) = makeSUT()
        
        expectConfirm(sut, toDeliver: [
            .failure(.server(statusCode: statusCode, errorMessage: errorMessage))
        ], on: {
            bindKeySpy.complete(with: .failure(.server(statusCode: statusCode, errorMessage: errorMessage)))
        })
    }
    
    func test_confirmActivation_shouldDeliverErrorOnBindKeyServiceFailure() {
        
        let (sut, _, _, bindKeySpy) = makeSUT()
        
        expectConfirm(sut, toDeliver: [.failure(.serviceFailure)], on: {
            
            bindKeySpy.complete(with: .failure(.serviceFailure))
        })
    }
    
    func test_confirmActivation_shouldDeliverVoidOnSuccess() {
        
        let (sut, _, _, bindKeySpy) = makeSUT()
        
        expectConfirm(sut, toDeliver: [.success(())], on: {
            
            bindKeySpy.complete(with: .success(()))
        })
    }
    
    func test_confirmActivation_shouldNotDeliverBindKeyResultOnInstanceDeallocation() {
        
        var sut: SUT?
        let bindKeySpy: BindKeySpy
        (sut, _, _, bindKeySpy) = makeSUT()
        var receivedResults = [SUT.ConfirmResult]()
        
        sut?.confirmActivation(withOTP: anyOTP()) { receivedResults.append($0) }
        sut = nil
        bindKeySpy.complete(with: .success(()))
        
        XCTAssert(receivedResults.isEmpty)
    }
    
    // MARK: - Helpers
    
    private typealias SUT = CVVPINFunctionalityActivationService
    private typealias GetCodeSpy = Spy<Void, SUT.GetCodeSuccess, SUT.GetCodeResponseError>
    private typealias FormSessionKeySpy = Spy<SUT.Code, SUT.FormSessionKeySuccess, SUT.FormSessionKeyError>
    private typealias BindKeySpy = Spy<SUT.OTP, Void, SUT.BindPublicKeyError>
    
    private func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        getCodeSpy: GetCodeSpy,
        formSessionKeySpy: FormSessionKeySpy,
        bindKeySpy: BindKeySpy
    ) {
        let getCodeSpy = GetCodeSpy()
        let formSessionKeySpy = FormSessionKeySpy()
        let bindKeySpy = BindKeySpy()
        let sut = SUT(
            getCode: getCodeSpy.process(completion:),
            formSessionKey: formSessionKeySpy.process(_:completion:),
            bindPublicKeyWithEventID: bindKeySpy.process(_:completion:)
        )
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(getCodeSpy, file: file, line: line)
        trackForMemoryLeaks(formSessionKeySpy, file: file, line: line)
        trackForMemoryLeaks(bindKeySpy, file: file, line: line)
        
        return (sut, getCodeSpy, formSessionKeySpy, bindKeySpy)
    }
    
    private func expectActivate(
        _ sut: SUT,
        toDeliver expectedResults: [SUT.ActivateResult],
        on action: @escaping () -> Void,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        var receivedResults = [SUT.ActivateResult]()
        let exp = expectation(description: "wait for completion")
        
        sut.activate {
            
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
    
    private func expectConfirm(
        _ sut: SUT,
        toDeliver expectedResults: [SUT.ConfirmResult],
        on action: @escaping () -> Void,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        var receivedResults = [SUT.ConfirmResult]()
        let exp = expectation(description: "wait for completion")
        
        sut.confirmActivation(withOTP: anyOTP()) {
            
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
}

private extension Array where Element == CVVPINFunctionalityActivationService.ActivateResult {
    
    func mapToEquatable() -> [CVVPINFunctionalityActivationService.ActivateResult.EquatableActivateResult] {
        
        map { $0.mapToEquatable() }
    }
}

private extension CVVPINFunctionalityActivationService.ActivateResult {
    
    func mapToEquatable() -> EquatableActivateResult {
        
        self
            .map(EquatableActivateSuccess.init(response:))
            .mapError(EquatableActivateError.init)
    }
    
    typealias EquatableActivateResult = Swift.Result<EquatableActivateSuccess, EquatableActivateError>
    
    struct EquatableActivateSuccess: Equatable {
        
        let codeValue: String
        let phoneValue: String
        let sessionKeyValue: Data
        let eventIDValue: String
        let sessionTTL: Int
        
        init(response: CVVPINFunctionalityActivationService.ActivateSuccess) {
            
            self.codeValue = response.code.codeValue
            self.phoneValue = response.phone.phoneValue
            self.sessionKeyValue = response.sessionKey.sessionKeyValue
            self.eventIDValue = response.eventID.eventIDValue
            self.sessionTTL = response.sessionTTL
        }
    }
    
    enum EquatableActivateError: Error & Equatable {
        
        case invalid(statusCode: Int, data: Data)
        case network
        case server(statusCode: Int, errorMessage: String)
        case serviceFailure
        
        init(error: CVVPINFunctionalityActivationService.ActivateError) {
            
            switch error {
            case let .invalid(statusCode: statusCode, data: data):
                self = .invalid(statusCode: statusCode, data: data)
                
            case .network:
                self = .network
                
            case let .server(statusCode: statusCode, errorMessage: errorMessage):
                self = .server(statusCode: statusCode, errorMessage: errorMessage)
                
            case .serviceFailure:
                self = .serviceFailure
            }
        }
    }
}

private extension Array where Element == CVVPINFunctionalityActivationService.ConfirmResult {
    
    func mapToEquatable() -> [CVVPINFunctionalityActivationService.ConfirmResult.EquatableConfirmResult] {
        
        map { $0.mapToEquatable() }
    }
}

private extension CVVPINFunctionalityActivationService.ConfirmResult {
    
    func mapToEquatable() -> EquatableConfirmResult {
        
        self
            .map(EquatableVoid.init)
            .mapError(EquatableConfirmError.init)
    }
    
    typealias EquatableConfirmResult = Swift.Result<EquatableVoid, EquatableConfirmError>
    
    struct EquatableVoid: Equatable {
        
        init(_ void: Void) {}
    }
    
    enum EquatableConfirmError: Error & Equatable {
        
        case invalid(statusCode: Int, data: Data)
        case network
        case retry(statusCode: Int, errorMessage: String, retryAttempts: Int)
        case server(statusCode: Int, errorMessage: String)
        case serviceFailure
        
        init(error: CVVPINFunctionalityActivationService.ConfirmError) {
            
            switch error {
            case let .invalid(statusCode: statusCode, data: data):
                self = .invalid(statusCode: statusCode, data: data)
                
            case .network:
                self = .network
                
            case let .retry(statusCode: statusCode, errorMessage: errorMessage, retryAttempts: retryAttempts):
                self = .retry(statusCode: statusCode, errorMessage: errorMessage, retryAttempts: retryAttempts)
                
            case let .server(statusCode: statusCode, errorMessage: errorMessage):
                self = .server(statusCode: statusCode, errorMessage: errorMessage)
                
            case .serviceFailure:
                self = .serviceFailure
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
    codeValue: String = UUID().uuidString,
    phoneValue: String = UUID().uuidString
) -> CVVPINFunctionalityActivationService.GetCodeResult {
    
    .success(.init(
        code: .init(codeValue: codeValue),
        phone: .init(phoneValue: phoneValue)
    ))
}

private func anySuccess(
    sessionKeyValue: Data = anyData(),
    eventIDValue: String = UUID().uuidString,
    sessionTTL: Int = 23
) -> CVVPINFunctionalityActivationService.FormSessionKeyResult {
    
    .success(
        .init(
            sessionKey: .init(sessionKeyValue: sessionKeyValue),
            eventID: .init(eventIDValue: eventIDValue),
            sessionTTL: sessionTTL
        )
    )
}

private func anyOTP(
    otpValue: String = .init(UUID().uuidString.prefix(6))
) -> CVVPINFunctionalityActivationService.OTP {
    
    .init(otpValue: otpValue)
}
