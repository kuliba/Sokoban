//
//  CheckActivationTests.swift
//  
//
//  Created by Igor Malyarov on 18.10.2023.
//

import CVVPINServices
import XCTest

final class CheckActivationTests: MakeComposerInfraTests {
    
    func test_checkActivation_shouldDeliverErrorOnLoadRSAKeyFailure() {
        
        let loadRSAKeyError = anyError("LoadRSAKeyFailure")
        let (sut, keyPairLoader) = makeSUT()
        
        let results = checkActivationResults(sut, on: {
            
            keyPairLoader.complete(with: .failure(loadRSAKeyError))
        })
        
        assertVoid(results, equalsTo: [.failure(loadRSAKeyError)])
    }
    
    func test_checkActivation_shouldDeliverSuccessOnLoadRSAKeySuccess() {
        
        let (sut, keyPairLoader) = makeSUT()
        
        let results = checkActivationResults(sut, on: {
            
            keyPairLoader.complete(with: .success(makeRSAKeyPair()))
        })
        
        assertVoid(results, equalsTo: [.success(())])
    }
    
    func test_checkActivation_shouldNotDeliverResultOnSUTInstanceDeallocation() {
        
        var sut: SUT?
        let keyPairLoader: RSAKeyPairLoaderSpy
        (sut, keyPairLoader) = makeSUT()
        
        var results = [Result<Void, Error>]()
        
        sut?.checkActivation() { results.append($0) }
        sut = nil
        keyPairLoader.complete(with: .success(makeRSAKeyPair()))
        
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.1)
        
        XCTAssertTrue(results.isEmpty)
    }
    
    // MARK: - Helpers
    
    private typealias SessionID = PublicKeyAuthenticationResponse.SessionID
    private typealias SUT = Composer<SessionID>
    
    private func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        keyPairLoader: RSAKeyPairLoaderSpy
    ) {
        
        let (infra, _, keyPairLoader, _, _, _, _, _) = makeCVVPINInfra(SessionID.self, file: file, line: line)
        let (remote, _, _, _) = makeCVVPRemote(SessionID.self, file: file, line: line)
        let sut = SUT(crypto: .test(), infra: infra, remote: remote)
        
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return (sut, keyPairLoader)
    }
    
    private func checkActivationResults(
        _ sut: SUT,
        on action: @escaping () -> Void
    ) -> [Result<Void, Error>] {
        
        var results = [Result<Void, Error>]()
        let exp = expectation(description: "wait for completion")
        
        sut.checkActivation() {
            
            results.append($0)
            exp.fulfill()
        }
        
        action()
        
        wait(for: [exp], timeout: 1.0)
        
        return results
    }
}
