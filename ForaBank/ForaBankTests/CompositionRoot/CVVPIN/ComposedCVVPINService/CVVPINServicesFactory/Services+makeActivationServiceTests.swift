//
//  Services+makeActivationServiceTests.swift
//  ForaBankTests
//
//  Created by Igor Malyarov on 09.11.2023.
//

import CVVPIN_Services
@testable import ForaBank
import XCTest

final class Services_makeActivationServiceTests: XCTestCase {
    
    func test_init_shouldNotCallCollaborators() {
        
        let (_, getCodeSpy, formSessionKeySpy, bindPublicKeySpy) = makeSUT()
        
        XCTAssertEqual(getCodeSpy.callCount, 0)
        XCTAssertEqual(formSessionKeySpy.callCount, 0)
        XCTAssertEqual(bindPublicKeySpy.callCount, 0)
    }
    
    func test_activate_shouldDeliverErrorOnGetCodeFailure() {
        
        let statusode = 500
        let invalidData = anyData()
        let (sut, getCodeSpy, _, _) = makeSUT()
        
        expectActivate(sut, toDeliver: .failure(.invalid(statusCode: statusode, data: invalidData)), on: {
            
            getCodeSpy.complete(with: .failure(.invalid(statusCode: statusode, data: invalidData)))
        })
    }
    
    func test_activate_shouldDeliverErrorOnFormSessionKeyInvalidFailure() {
        
        let statusCode = 500
        let invalidData = anyData()
        let (sut, getCodeSpy, formSessionKeySpy, _) = makeSUT()
        
        expectActivate(sut, toDeliver: .failure(.invalid(statusCode: statusCode, data: invalidData)), on: {
            
            getCodeSpy.complete(with: anySuccess())
            formSessionKeySpy.complete(with: .failure(.invalid(statusCode: statusCode, data: invalidData)))
        })
    }
    
    func test_activate_shouldDeliverErrorOnFormSessionKeyNetworkFailure() {
        
        let (sut, getCodeSpy, formSessionKeySpy, _) = makeSUT()
        
        expectActivate(sut, toDeliver: .failure(.network), on: {
            
            getCodeSpy.complete(with: anySuccess())
            formSessionKeySpy.complete(with: .failure(.network))
        })
    }
    
    func test_activate_shouldDeliverErrorOnFormSessionKeyServerFailure() {
        
        let statusode = 500
        let errorMessage = "Server Failure"
        let (sut, getCodeSpy, formSessionKeySpy, _) = makeSUT()
        
        expectActivate(sut, toDeliver: .failure(.server(statusCode: statusode, errorMessage: errorMessage)), on: {
            
            getCodeSpy.complete(with: anySuccess())
            formSessionKeySpy.complete(with: .failure(.server(statusCode: statusode, errorMessage: errorMessage)))
        })
    }
    
    func test_activate_shouldDeliverErrorOnFormSessionKeyServiceFailureMakeJSONFailure() {
        
        let (sut, getCodeSpy, formSessionKeySpy, _) = makeSUT()
        
        expectActivate(sut, toDeliver: .failure(.serviceFailure), on: {
            
            getCodeSpy.complete(with: anySuccess())
            formSessionKeySpy.complete(with: .failure(.serviceError(.makeJSONFailure)))
        })
    }
    
    func test_activate_shouldDeliverErrorOnFormSessionKeyServiceFailureMakeSessionKeyFailure() {
        
        let (sut, getCodeSpy, formSessionKeySpy, _) = makeSUT()
        
        expectActivate(sut, toDeliver: .failure(.serviceFailure), on: {
            
            getCodeSpy.complete(with: anySuccess())
            formSessionKeySpy.complete(with: .failure(.serviceError(.makeSessionKeyFailure)))
        })
    }
    
    func test_activate_shouldDeliverErrorOnFormSessionKeyServiceFailureMissingCodeFailure() {
        
        let (sut, getCodeSpy, formSessionKeySpy, _) = makeSUT()
        
        expectActivate(sut, toDeliver: .failure(.serviceFailure), on: {
            
            getCodeSpy.complete(with: anySuccess())
            formSessionKeySpy.complete(with: .failure(.serviceError(.missingCode)))
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
            toDeliver: .success(.init(
                code: .init(codeValue: codeValue),
                phone: .init(phoneValue: phoneValue),
                sessionKey: .init(sessionKeyValue: sessionKeyValue),
                eventID: .init(eventIDValue: eventIDValue),
                sessionTTL: sessionTTL
            )),
            on: {
                getCodeSpy.complete(with: .success(.init(
                    code: .init(codeValue),
                    phone: .init(phoneValue)
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
        
        let phone = "+7..8976"
        var sut: SUT?
        let getCodeSpy: GetCodeService
        (sut, getCodeSpy, _, _) = makeSUT()
        var receivedResult: SUT.ActivateResult?
        
        sut?.activate { receivedResult = $0 }
        sut = nil
        getCodeSpy.complete(with: anySuccess(phone: phone))
        
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.05)
        
        XCTAssertNil(receivedResult)
    }
    
    func test_activate_shouldNotDeliverFormSessionKeyResultOnInstanceDeallocation() {
        
        let phone = "+7..8976"
        var sut: SUT?
        let getCodeSpy: GetCodeService
        let formSessionKeySpy: FormKeyService
        (sut, getCodeSpy, formSessionKeySpy, _) = makeSUT()
        var receivedResult: SUT.ActivateResult?
        
        sut?.activate { receivedResult = $0 }
        getCodeSpy.complete(with: anySuccess(phone: phone))
        sut = nil
        formSessionKeySpy.complete(with: anySuccess())
        
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.05)

        XCTAssertNil(receivedResult)
    }
    
    func test_confirmActivation_shouldDeliverErrorOnBindKeyInvalidFailure() {
        
        let statusCode = 500
        let invalidData = anyData()
        let (sut, _, _, bindPublicKeySpy) = makeSUT()
        
        expectConfirm(sut, toDeliver: .failure(.invalid(statusCode: statusCode, data: invalidData)), on: {
            
            bindPublicKeySpy.complete(with: .failure(.invalid(statusCode: statusCode, data: invalidData)))
        })
    }
    
    func test_confirmActivation_shouldDeliverVoidOnSuccess() {
        
        let (sut, _, _, bindPublicKeySpy) = makeSUT()
        
        expectConfirm(sut, toDeliver: .success(()), on: {
            
            bindPublicKeySpy.complete(with: .success(()))
        })
    }
    
    func test_confirmActivation_shouldNotDeliverBindKeyResultOnInstanceDeallocation() {
        
        var sut: SUT?
        let bindPublicKeySpy: BindPublicKeyService
        (sut, _, _, bindPublicKeySpy) = makeSUT()
        var receivedResult: SUT.ConfirmResult?
        
        sut?.confirmActivation(withOTP: anyOTO()) { receivedResult = $0 }
        sut = nil
        bindPublicKeySpy.complete(with: .success(()))
        
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.05)
        
        XCTAssertNil(receivedResult)
    }
    
    // MARK: - Helpers
    
    private typealias SUT = CVVPINFunctionalityActivationService
    private typealias GetCodeService = Spy<Void, GetProcessingSessionCodeService.Response, GetProcessingSessionCodeService.Error>
    private typealias FormKeyService = Spy<FormSessionKeyService.Code, FormSessionKeyService.Success, FormSessionKeyService.Error>
    private typealias BindPublicKeyService = Spy<BindPublicKeyWithEventIDService.OTP, Void, BindPublicKeyWithEventIDService.Error>
    
    private func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        getCodeSpy: GetCodeService,
        formSessionKeySpy: FormKeyService,
        bindPublicKeySpy: BindPublicKeyService
    ) {
        
        let getCodeSpy = GetCodeService()
        let formSessionKeySpy = FormKeyService()
        let bindPublicKeySpy = BindPublicKeyService()
        
        let sut = Services.makeActivationService(
            getCode: getCodeSpy.fetch,
            formSessionKey: formSessionKeySpy.fetch,
            bindPublicKeyWithEventID: bindPublicKeySpy.process(_:completion:)
        )
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(getCodeSpy, file: file, line: line)
        trackForMemoryLeaks(formSessionKeySpy, file: file, line: line)
        trackForMemoryLeaks(bindPublicKeySpy, file: file, line: line)
        
        return (sut, getCodeSpy, formSessionKeySpy, bindPublicKeySpy)
    }
    
    private func expectActivate(
        _ sut: SUT,
        toDeliver expectedResult: SUT.ActivateResult,
        on action: @escaping () -> Void,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let exp = expectation(description: "wait for completion")
        
        sut.activate { receivedResult in
            
            switch (receivedResult, expectedResult) {
            case let (
                .failure(received),
                .failure(expected)
            ):
                switch (received, expected) {
                case let (
                    .invalid(receivedStatusCode, receivedInvalidData),
                    .invalid(expectedStatusCode, expectedInvalidData)
                ):
                    XCTAssertNoDiff(receivedStatusCode, expectedStatusCode, file: file, line: line)
                    XCTAssertNoDiff(receivedInvalidData, expectedInvalidData, file: file, line: line)
                    
                case (.network, .network):
                    break
                    
                case let (
                    .server(receivedStatusCode, receivedErrorMessage),
                    .server(expectedStatusCode, expectedErrorMessage)
                ):
                    XCTAssertNoDiff(receivedStatusCode, expectedStatusCode, file: file, line: line)
                    XCTAssertNoDiff(receivedErrorMessage, expectedErrorMessage, file: file, line: line)
                    
                case (.serviceFailure, .serviceFailure):
                    break
                    
                default:
                    XCTFail("\nExpected \(expected), but got \(received) instead.", file: file, line: line)
                }
                
            case let (.success(received), .success(expected)):
                XCTAssertNoDiff(received.equatable, expected.equatable, file: file, line: line)
                
            default:
                XCTFail("\nExpected \(expectedResult), but got \(receivedResult) instead.", file: file, line: line)
            }
            
            exp.fulfill()
        }
        
        action()
        
        wait(for: [exp], timeout: 1.0)
    }
    
    private func expectConfirm(
        _ sut: SUT,
        toDeliver expectedResult: SUT.ConfirmResult,
        on action: @escaping () -> Void,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let exp = expectation(description: "wait for completion")
        
        sut.confirmActivation(withOTP: anyOTO()) { receivedResult in
            
            switch (receivedResult, expectedResult) {
            case let (
                .failure(received),
                .failure(expected)
            ):
                switch (received, expected) {
                case let (
                    .invalid(receivedStatusCode, receivedInvalidData),
                    .invalid(expectedStatusCode, expectedInvalidData)
                ):
                    XCTAssertNoDiff(receivedStatusCode, expectedStatusCode, file: file, line: line)
                    XCTAssertNoDiff(receivedInvalidData, expectedInvalidData, file: file, line: line)
                    
                case (.network, .network):
                    break
                    
                case let (
                    .retry(receivedStatusCode, receivedErrorMessage, receivedRetryAttempts),
                    .retry(expectedStatusCode, expectedErrorMessage, expectedRetryAttempts)
                ):
                    XCTAssertNoDiff(receivedStatusCode, expectedStatusCode, file: file, line: line)
                    XCTAssertNoDiff(receivedErrorMessage, expectedErrorMessage, file: file, line: line)
                    XCTAssertNoDiff(receivedRetryAttempts, expectedRetryAttempts, file: file, line: line)
                    
                case let (
                    .server(receivedStatusCode, receivedErrorMessage),
                    .server(expectedStatusCode, expectedErrorMessage)
                ):
                    XCTAssertNoDiff(receivedStatusCode, expectedStatusCode, file: file, line: line)
                    XCTAssertNoDiff(receivedErrorMessage, expectedErrorMessage, file: file, line: line)
                    
                case (.serviceFailure, .serviceFailure):
                    break
                    
                default:
                    XCTFail("\nExpected \(expected), but got \(received) instead.", file: file, line: line)
                }
                
            case (.success(()), .success(())):
                break

            default:
                XCTFail("\nExpected \(expectedResult), but got \(receivedResult) instead.", file: file, line: line)
            }
            
            exp.fulfill()
        }
        
        action()
        
        wait(for: [exp], timeout: 1.0)
    }
}

private extension CVVPINFunctionalityActivationService.ActivateSuccess {
    
    var equatable: EquatableActivateSuccess {
    
        .init(response: self)
    }
    
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
}

private extension CVVPINFunctionalityActivationService.ActivateResult {
    
    func mapToEquatable() -> EquatableActivateResult {
        
        self
            .map(CVVPINFunctionalityActivationService.ActivateSuccess.EquatableActivateSuccess.init(response:))
            .mapError(EquatableActivateError.init)
    }
    
    typealias EquatableActivateResult = Swift.Result<CVVPINFunctionalityActivationService.ActivateSuccess.EquatableActivateSuccess, EquatableActivateError>
    
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

private func anySuccess(
    code: String = UUID().uuidString,
    phone: String = UUID().uuidString
) -> Result<GetProcessingSessionCodeService.Response, GetProcessingSessionCodeService.Error> {
    
    .success(.init(code: code, phone: phone))
}

private func anySuccess(
    sessionKeyValue: Data = anyData(),
    eventIDValue: String = UUID().uuidString,
    sessionTTLValue: Int = 31
) -> Result<FormSessionKeyService.Success, FormSessionKeyService.Error> {
    
    .success(.init(
        sessionKey: .init(sessionKeyValue: sessionKeyValue),
        eventID: .init(eventIDValue: eventIDValue),
        sessionTTL: sessionTTLValue
    ))
}

private func anyOTO(
    otpValue: String = UUID().uuidString
) -> CVVPINFunctionalityActivationService.OTP {
    
    .init(otpValue: otpValue)
}
