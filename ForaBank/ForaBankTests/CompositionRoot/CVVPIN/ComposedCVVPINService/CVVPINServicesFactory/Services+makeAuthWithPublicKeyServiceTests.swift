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
    
    private final class CacheSpy {
        
        private(set) var callCount: Int = 0
        
        func cache(
            success: AuthenticateWithPublicKeyService.Success
        ) {
            callCount += 1
        }
    }
}
