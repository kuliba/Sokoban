//
//  Services+makeAuthWithPublicKeyServiceTests.swift
//  ForaBankTests
//
//  Created by Igor Malyarov on 09.11.2023.
//

import CVVPIN_Services
@testable import ForaBank
import XCTest

@available(iOS 16.0.0, *)
final class Services_makeAuthWithPublicKeyServiceTests: XCTestCase {
    
    func test_init_shouldNotCallCollaborators() {
        
        let (_, prepareKeyExchangeSpy, authRemoteServiceSpy, makeSessionKeySpy, cacheSpy) = makeSUT()
        
        XCTAssertEqual(prepareKeyExchangeSpy.callCount, 0)
        XCTAssertEqual(authRemoteServiceSpy.callCount, 0)
        XCTAssertEqual(makeSessionKeySpy.callCount, 0)
        XCTAssertEqual(cacheSpy.callCount, 0)
    }
    
    func test_fetch_shouldDeliverErrorOnPrepareExchangeFailure() {
        
        let (sut, prepareKeyExchangeSpy, _, _, _) = makeSUT()
        
        expect(sut, toDeliver: .failure(.serviceError(.prepareKeyExchangeFailure)), on: {
            
            prepareKeyExchangeSpy.complete(with: .failure(anyError()))
        })
    }
    
    func test_fetch_shouldDeliverErrorOnAuthRemoteServiceCreateRequestFailure() {
        
        let (sut, prepareKeyExchangeSpy, authRemoteServiceSpy, _, _) = makeSUT()
        
        expect(sut, toDeliver: .failure(.network), on: {
            
            prepareKeyExchangeSpy.complete(with: .success(anyData()))
            authRemoteServiceSpy.complete(with: .failure(.createRequest(anyError())))
        })
    }
    
    func test_fetch_shouldDeliverErrorOnAuthRemoteServicePerformRequestFailure() {
        
        let (sut, prepareKeyExchangeSpy, authRemoteServiceSpy, _, _) = makeSUT()
        
        expect(sut, toDeliver: .failure(.network), on: {
            
            prepareKeyExchangeSpy.complete(with: .success(anyData()))
            authRemoteServiceSpy.complete(with: .failure(.performRequest(anyError())))
        })
    }
    
    func test_fetch_shouldDeliverErrorOnAuthRemoteServiceMapResponseInvalidFailure() {
        
        let statusCode = 500
        let invalidData = anyData()
        let (sut, prepareKeyExchangeSpy, authRemoteServiceSpy, _, _) = makeSUT()
        
        expect(sut, toDeliver: .failure(.invalid(statusCode: statusCode, data: invalidData)), on: {
            
            prepareKeyExchangeSpy.complete(with: .success(anyData()))
            authRemoteServiceSpy.complete(with: .failure(.mapResponse(.invalid(statusCode: statusCode, data: invalidData))))
        })
    }
    
    func test_fetch_shouldDeliverErrorOnAuthRemoteServiceMapResponseNetworkFailure() {
        
        let (sut, prepareKeyExchangeSpy, authRemoteServiceSpy, _, _) = makeSUT()
        
        expect(sut, toDeliver: .failure(.network), on: {
            
            prepareKeyExchangeSpy.complete(with: .success(anyData()))
            authRemoteServiceSpy.complete(with: .failure(.mapResponse(.network)))
        })
    }
    
    func test_fetch_shouldDeliverErrorOnAuthRemoteServiceMapResponseServerFailure() {
        
        let statusCode = 500
        let errorMessage = "Map Response Failure"
        let (sut, prepareKeyExchangeSpy, authRemoteServiceSpy, _, _) = makeSUT()
        
        expect(sut, toDeliver: .failure(.server(statusCode: statusCode, errorMessage: errorMessage)), on: {
            
            prepareKeyExchangeSpy.complete(with: .success(anyData()))
            authRemoteServiceSpy.complete(with: .failure(.mapResponse(.server(statusCode: statusCode, errorMessage: errorMessage))))
        })
    }
    
    func test_fetch_shouldDeliverErrorOnMakeSessionKeyFailure() {
        
        let (sut, prepareKeyExchangeSpy, authRemoteServiceSpy, makeSessionKeySpy, _) = makeSUT()
        
        expect(sut, toDeliver: .failure(.serviceError(.makeSessionKeyFailure)), on: {
            
            prepareKeyExchangeSpy.complete(with: .success(anyData()))
            authRemoteServiceSpy.complete(with: anySuccess())
            makeSessionKeySpy.complete(with: .failure(anyError()))
        })
    }
    
    func test_fetch_shouldDeliverValueOnSuccess() {
        
        let sessionIDValue = UUID().uuidString
        let publicServerSessionKeyValue = UUID().uuidString
        let sessionTTL = 11
        let sessionKeyValue = anyData()
        let (sut, prepareKeyExchangeSpy, authRemoteServiceSpy, makeSessionKeySpy, _) = makeSUT()
        
        expect(sut, toDeliver: .success(.init(
            sessionID: .init(sessionIDValue: sessionIDValue),
            sessionKey: .init(sessionKeyValue: sessionKeyValue),
            sessionTTL: sessionTTL
        )), on: {
            
            prepareKeyExchangeSpy.complete(with: .success(anyData()))
            authRemoteServiceSpy.complete(with: anySuccess(
                sessionIDValue: sessionIDValue,
                sessionTTL: sessionTTL
            ))
            makeSessionKeySpy.complete(with: .success(.init(sessionKeyValue: sessionKeyValue)))
        })
    }
    
    // MARK: - Helpers
    
    private typealias SUT = Services.AuthWithPublicKeyService
    private typealias PrepareKeyExchangeSpy = FetcherSpy<Void, Data, Error>
    private typealias AuthRemoteServiceSpy = FetcherSpy<Data, AuthenticateWithPublicKeyService.Response, MappingRemoteServiceError<AuthenticateWithPublicKeyService.APIError>>
    private typealias MakeSessionKeySpy = FetcherSpy<AuthenticateWithPublicKeyService.Response, AuthenticateWithPublicKeyService.Success.SessionKey, Error>
    
    private func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: any SUT,
        prepareKeyExchangeSpy: PrepareKeyExchangeSpy,
        authRemoteServiceSpy: AuthRemoteServiceSpy,
        makeSessionKeySpy: MakeSessionKeySpy,
        cacheSpy: CacheSpy
    ) {
        let prepareKeyExchangeSpy = PrepareKeyExchangeSpy()
        let authRemoteServiceSpy = AuthRemoteServiceSpy()
        let makeSessionKeySpy = MakeSessionKeySpy()
        let cacheSpy = CacheSpy()
        let sut = Services.makeAuthWithPublicKeyService(
            prepareKeyExchange: prepareKeyExchangeSpy.fetch,
            authRemoteService: authRemoteServiceSpy,
            makeSessionKey: makeSessionKeySpy.fetch,
            cache: cacheSpy.cache(success:)
        )
        
        trackForMemoryLeaks(prepareKeyExchangeSpy, file: file, line: line)
        trackForMemoryLeaks(authRemoteServiceSpy, file: file, line: line)
        trackForMemoryLeaks(makeSessionKeySpy, file: file, line: line)
        trackForMemoryLeaks(cacheSpy, file: file, line: line)
        
        return (sut, prepareKeyExchangeSpy, authRemoteServiceSpy, makeSessionKeySpy, cacheSpy)
    }
    
    private func expect(
        _ sut: any SUT,
        toDeliver expectedResult: Result<AuthenticateWithPublicKeyService.Success, AuthenticateWithPublicKeyService.Error>,
        on action: @escaping () -> Void,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let exp = expectation(description: "wait for completion")
        
        sut.fetch { receivedResult in
            
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
                
            case let (
                .failure(.serviceError(receivedServiceError)),
                .failure(.serviceError(expectedServiceError))
            ):
                switch (receivedServiceError, expectedServiceError) {
                case (.activationFailure, .activationFailure),
                    (.makeSessionKeyFailure, .makeSessionKeyFailure),
                    (.missingRSAPublicKey, .missingRSAPublicKey),
                    (.prepareKeyExchangeFailure, .prepareKeyExchangeFailure):
                    break
                    
                default:
                    XCTFail("\nExpected \(expectedServiceError), but got \(receivedServiceError) instead.", file: file, line: line)
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
    
    private final class CacheSpy {
        
        private(set) var callCount: Int = 0
        
        func cache(
            success: AuthenticateWithPublicKeyService.Success
        ) {
            callCount += 1
        }
    }
}

private extension AuthenticateWithPublicKeyService.Success {
    
    var equatable: EquatableSuccess {
        
        .init(
            sessionIDValue: sessionID.sessionIDValue,
            sessionKeyValue: sessionKey.sessionKeyValue,
            sessionTTL: sessionTTL
        )
    }
    
    struct EquatableSuccess: Equatable {
        
        let sessionIDValue: String
        let sessionKeyValue: Data
        let sessionTTL: Int
    }
}

private func anySuccess(
    sessionIDValue: String = UUID().uuidString,
    publicServerSessionKeyValue: String = UUID().uuidString,
    sessionTTL: Int = 45
) -> Result<AuthenticateWithPublicKeyService.Response, MappingRemoteServiceError<AuthenticateWithPublicKeyService.APIError>> {
    
    .success(.init(
        sessionID: sessionIDValue,
        publicServerSessionKey: publicServerSessionKeyValue,
        sessionTTL: sessionTTL
    ))
}
