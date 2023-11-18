//
//  CVVPINSessionCacheTests.swift
//  ForaBankTests
//
//  Created by Igor Malyarov on 14.11.2023.
//

import CVVPIN_Services
@testable import ForaBank
import XCTest

final class CVVPINSessionCacheTests: XCTestCase {
    
    func test_init_shouldNotCallCollaborators() {
        
        let (_, cacheSessionIDSpy, cacheSessionKeySpy) = makeSUT()
        
        XCTAssertEqual(cacheSessionIDSpy.callCount, 0)
        XCTAssertEqual(cacheSessionKeySpy.callCount, 0)
    }
    
    func test_handleActivateResult_shouldDeliverErrorOnFailure() {
        
        let (sut, _,_) = makeSUT()
        
        expect(sut, with: .failure(.network), toDeliver: .failure(.network)) {}
    }
    
    func test_handleActivateResult_shouldDeliverErrorOnCacheSessionIDFailure() {
        
        let (sut, cacheSessionIDSpy, _) = makeSUT()
        
        expect(sut, toDeliver: .failure(.serviceFailure)) {
            
            cacheSessionIDSpy.complete(with: .failure(anyError()))
        }
    }
    
    func test_handleActivateResult_shouldDeliverErrorOnCacheSessionKeyFailure() {
        
        let (sut, cacheSessionIDSpy, cacheSessionKeySpy) = makeSUT()
        
        expect(sut, toDeliver: .failure(.serviceFailure)) {
            
            cacheSessionIDSpy.complete(with: .success(()))
            cacheSessionKeySpy.complete(with: .failure(anyError()))
        }
    }
    
    func test_handleActivateResult_shouldDeliverResultOnSuccess() {
        
        let success = anyActivateSuccess()
        let (sut, cacheSessionIDSpy, cacheSessionKeySpy) = makeSUT()
        
        expect(sut, with: .success(success), toDeliver: .success(success)) {
            
            cacheSessionIDSpy.complete(with: .success(()))
            cacheSessionKeySpy.complete(with: .success(()))
        }
    }
    
    func test_handleActivateResult_shouldNotDeliverCacheSessionIDResultOnInstanceDeallocation() {
        
        var sut: SUT?
        let cacheSessionIDSpy: CacheSessionIDSpy
        (sut, cacheSessionIDSpy, _) = makeSUT()
        var receivedResult: SUT.ActivateResult?
        
        sut?.handleActivateResult(.success(anyActivateSuccess())) { receivedResult = $0 }
        sut = nil
        cacheSessionIDSpy.complete(with: .success(()))
        
        XCTAssertNil(receivedResult)
    }
    
    func test_handleActivateResult_shouldNotDeliverCacheSessionKeyResultOnInstanceDeallocation() {
        
        var sut: SUT?
        let cacheSessionIDSpy: CacheSessionIDSpy
        let cacheSessionKeySpy: CacheSessionKeySpy
        (sut, cacheSessionIDSpy, cacheSessionKeySpy) = makeSUT()
        var receivedResult: SUT.ActivateResult?
        
        sut?.handleActivateResult(.success(anyActivateSuccess())) { receivedResult = $0 }
        cacheSessionIDSpy.complete(with: .success(()))
        sut = nil
        cacheSessionKeySpy.complete(with: .success(()))
        
        XCTAssertNil(receivedResult)
    }
    
    // MARK: - Helpers
    
    private typealias SUT = CVVPINSessionCache
    private typealias ActivateSuccess = CVVPINInitiateActivationService.ActivateSuccess
    private typealias ActivateError = CVVPINInitiateActivationService.ActivateError
    private typealias CacheSessionIDSpy = Spy<(SessionID, Date), Void, Error>
    private typealias CacheSessionKeySpy = Spy<(SessionKey, Date), Void, Error>
    
    private func makeSUT(
        currentDate: @escaping SUT.CurrentDate = Date.init,
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        cacheSessionIDSpy: CacheSessionIDSpy,
        cacheSessionKeySpy: CacheSessionKeySpy
    ) {
        let cacheSessionIDSpy = CacheSessionIDSpy()
        let cacheSessionKeySpy = CacheSessionKeySpy()
        let sut = SUT(
            cacheSessionID: cacheSessionIDSpy.process,
            cacheSessionKey: cacheSessionKeySpy.process,
            currentDate: currentDate
        )
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(cacheSessionIDSpy, file: file, line: line)
        trackForMemoryLeaks(cacheSessionKeySpy, file: file, line: line)
        
        return (sut, cacheSessionIDSpy, cacheSessionKeySpy)
    }
    
    private func expect(
        _ sut: SUT,
        with payload: SUT.ActivateResult = anyPayload(),
        toDeliver expectedResult: SUT.ActivateResult,
        on action: @escaping () -> Void,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let exp = expectation(description: "wait for completion")
        
        sut.handleActivateResult(payload) { receivedResult in
            
            switch (receivedResult, expectedResult) {
            case let (
                .failure(.invalid(statusCode: receivedStatusCode, data: receivedInvalidData)),
                .failure(.invalid(statusCode: expectedStatusCode, data: expectedInvalidData))
            ):
                XCTAssertNoDiff(receivedStatusCode, expectedStatusCode, file: file, line: line)
                XCTAssertNoDiff(receivedInvalidData, expectedInvalidData, file: file, line: line)
                
            case (.failure(.network), .failure(.network)):
                break
                
            case let (
                .failure(.server(statusCode: receivedStatusCode, errorMessage: receivedErrorMessage)),
                .failure(.server(statusCode: expectedStatusCode, errorMessage: expectedErrorMessage))
            ):
                XCTAssertNoDiff(receivedStatusCode, expectedStatusCode, file: file, line: line)
                XCTAssertNoDiff(receivedErrorMessage, expectedErrorMessage, file: file, line: line)
                
            case (.failure(.serviceFailure), .failure(.serviceFailure)):
                break
                
            case let (.success(receivedSuccess), .success(expectedSuccess)):
                XCTAssertNoDiff(receivedSuccess.equatable, expectedSuccess.equatable, file: file, line: line)
                
            default:
                XCTFail("\nExpected \(expectedResult), but got \(receivedResult) instead.", file: file, line: line)
            }
            
            exp.fulfill()
        }
        
        action()
        
        wait(for: [exp], timeout: 1.0)
    }
}

private extension CVVPINInitiateActivationService.ActivateSuccess {
    
    var equatable: EquatableActivateSuccess {
        
        .init(
            code: code.codeValue,
            phone: phone.phoneValue,
            sessionKey: sessionKey.sessionKeyValue,
            eventID: eventID.eventIDValue,
            sessionTTL: sessionTTL
        )
    }
    
    struct EquatableActivateSuccess: Equatable {
        
        let code: String
        let phone: String
        let sessionKey: Data
        let eventID: String
        let sessionTTL: Int
    }
}

private func anyPayload(
) -> CVVPINInitiateActivationService.ActivateResult {
    
    .success(anyActivateSuccess())
}

private func anyPayload(
) -> Result<CVVPINInitiateActivationService.ActivateSuccess, Error> {
    
    .success(anyActivateSuccess())
}

private func anyActivateSuccess(
    codeValue: String = UUID().uuidString,
    phoneValue: String = UUID().uuidString,
    sessionKeyValue: Data = anyData(),
    eventIDValue: String = UUID().uuidString,
    sessionTTL: Int = 17
) -> CVVPINInitiateActivationService.ActivateSuccess {
    
    .init(
        code: .init(codeValue: codeValue),
        phone: .init(phoneValue: phoneValue),
        sessionKey: .init(sessionKeyValue: sessionKeyValue),
        eventID: .init(eventIDValue: eventIDValue),
        sessionTTL: sessionTTL
    )
}
