//
//  SecretRequestMakerTests.swift
//  
//
//  Created by Igor Malyarov on 19.08.2023.
//

@testable import CvvPin
import XCTest

final class SecretRequestMakerTests: XCTestCase {
    
    func test_makeSecretRequest_shouldThrowOnPublicKeyDataError() throws {
        
        let publicKeyDataError = NSError(domain: "PublicKeyData Error", code: 0)
        let sessionCode = anySessionCode()
        let sut = makeSUT(publicKeyData: { throw publicKeyDataError })
        
        XCTAssertThrowsAsNSError(
            try sut.makeSecretRequest(sessionCode: sessionCode),
            error: publicKeyDataError
        )
    }
    
    func test_makeSecretRequest_shouldThrowOnEncryptError() throws {
        
        let encryptError = NSError(domain: "PublicKeyData Error", code: 0)
        let sessionCode = anySessionCode()
        let sut = makeSUT(
            publicKeyData: Data.init,
            encrypt: { _ in throw encryptError }
        )
        
        XCTAssertThrowsAsNSError(
            try sut.makeSecretRequest(sessionCode: sessionCode),
            error: encryptError
        )
    }
    
    func test_makeSecretRequest_shouldWrapDataInSecretRequest() throws {
        
        let message = "some data"
        let sessionCode = "abc123"
        let sut = makeSUT(message: "some data")
        
        let request = try sut.makeSecretRequest(
            sessionCode: .init(value: sessionCode)
        )
        
        XCTAssertEqual(request.code.value, sessionCode)
        let unwrapped = try unwrap(XCTUnwrap(request.data))
        XCTAssertEqual(
            String(data: unwrapped, encoding: .utf8),
            message
        )
    }
    
    // MARK: - Helpers
    
    private let unwrap = PublicApplicationSessionKeyJSONWrapper.unwrap
    
    private func makeSUT(
        message: String,
        encrypt: @escaping SecretRequestMaker.Encrypt = { $0 },
        file: StaticString = #file,
        line: UInt = #line
    ) -> SecretRequestMaker {
        
        makeSUT(
            publicKeyData: { message.data(using: .utf8)! },
            encrypt: encrypt,
            file: file,
            line: line
        )
    }
    
    private func makeSUT(
        publicKeyData: @escaping SecretRequestMaker.PublicKeyData,
        encrypt: @escaping SecretRequestMaker.Encrypt = { $0 },
        file: StaticString = #file,
        line: UInt = #line
    ) -> SecretRequestMaker {
        
        let sut = SecretRequestMaker(
            publicKeyData: publicKeyData,
            encrypt: encrypt
        )
        
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return sut
    }
    
    private func anySessionCode(
        _ value: String = "abc123"
    ) -> KeyExchangeDomain.SessionCode {
        
        .init(value: value)
    }
}
