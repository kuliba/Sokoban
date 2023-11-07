//
//  AuthenticateWithPublicKeyService+FetcherTests.swift
//  ForaBankTests
//
//  Created by Igor Malyarov on 07.11.2023.
//

import CVVPIN_Services
import Fetcher
@testable import ForaBank
import XCTest

final class AuthenticateWithPublicKeyService_FetcherTests: XCTestCase {
    
    // MARK: - Helpers
    
    private typealias SUT = AuthenticateWithPublicKeyService
    
    private func makeSUT(
        prepareKeyExchangeResult: SUT.PrepareKeyExchangeResult = anySuccess(),
        processResult: SUT.ProcessResult = anySuccess(),
        makeSessionKeyResult: SUT.MakeSessionKeyResult = anySuccess(),
        file: StaticString = #file,
        line: UInt = #line
    ) -> SUT {
        
        let sut = SUT(
            prepareKeyExchange: { $0(.init {
                
                try prepareKeyExchangeResult.get()
            })},
            process: { _, completion in
                
                completion(processResult)
            },
            makeSessionKey: { _, completion in
                
                completion(.init {
                
                try makeSessionKeyResult.get()
            })}
        )
        
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return sut
    }
}

private func anySuccess(
    data: Data = anyData()
) -> AuthenticateWithPublicKeyService.PrepareKeyExchangeResult {
    
    .success(data)
}

private func anySuccess(
    sessionID: String = UUID().uuidString,
    publicServerSessionKey: String = UUID().uuidString,
    sessionTTL: Int = 42
) -> AuthenticateWithPublicKeyService.ProcessResult {
    
    .success(.init(
        sessionID: sessionID,
        publicServerSessionKey: publicServerSessionKey,
        sessionTTL: sessionTTL
    ))
}

private func anySuccess(
    sessionKeyValue: Data = anyData()
) -> AuthenticateWithPublicKeyService.MakeSessionKeyResult {
    
    .success(.init(sessionKeyValue: sessionKeyValue))
}
