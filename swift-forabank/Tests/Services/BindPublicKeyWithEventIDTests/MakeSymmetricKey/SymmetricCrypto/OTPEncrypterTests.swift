//
//  OTPEncrypterTests.swift
//  
//
//  Created by Igor Malyarov on 07.08.2023.
//

import BindPublicKeyWithEventID
import XCTest

final class OTPEncrypterTests: XCTestCase {
    
    func test_init_shouldNotCallEncryption() throws {
        
        let (_, spy) = makeSUT()
        
        XCTAssertEqual(spy.encryptionCallCount, 0)
    }
    
    func test_encrypt_shouldFailOnEncryptWithPaddingError() throws {
        
        let (otp, privateRSAKey) = makeOTPAndKey()
        let encryptWithPaddingError = anyError("encryptWithPaddingError")
        let (sut, _) = makeSUT(
            encryptWithPaddingResult: .failure(encryptWithPaddingError)
        )
        
        try XCTAssertThrowsError(sut.encrypt(otp, withRSAKey: privateRSAKey)) {
            
            XCTAssertNoDiff(
                $0 as NSError,
                encryptWithPaddingError as NSError
            )
        }
    }
    
    func test_encrypt_shouldFailOnEncryptWithTransportPublicRSAKeyError() throws {
        
        let (otp, privateRSAKey) = makeOTPAndKey()
        let encryptWithTransportPublicRSAKeyError = anyError("encryptWithTransportPublicRSAKeyError")
        let (sut, _) = makeSUT(
            encryptWithPaddingResult: .success(anyData()),
            encryptWithTransportPublicRSAKeyResult: .failure(encryptWithTransportPublicRSAKeyError)
        )
        
        try XCTAssertThrowsError(sut.encrypt(otp, withRSAKey: privateRSAKey)) {
            
            XCTAssertNoDiff(
                $0 as NSError,
                encryptWithTransportPublicRSAKeyError as NSError
            )
        }
    }
    
    func test_encrypt_shouldDeliverDataOnSuccessfulEncryption() throws {
        
        let (otp, privateRSAKey) = makeOTPAndKey()
        let validData = "valid data".data(using: .utf8)!
        let (sut, _) = makeSUT(
            encryptWithTransportPublicRSAKeyResult: .success(validData)
        )
        
        let data = try sut.encrypt(otp, withRSAKey: privateRSAKey)
        
        XCTAssertNoDiff(data, validData)
    }
    
    // MARK: - Helpers
    
    private typealias TestOTPEncrypter = OTPEncrypter<TestPrivateKey>
    
    private func makeOTPAndKey() -> (OTP, TestPrivateKey) {
        
        let otp = OTP(value: "any OTP")
        let privateRSAKey = anyTestPrivateKey()
        
        return (otp, privateRSAKey)
    }
    
    private func makeSUT(
        encryptWithPaddingResult: EncryptWithPaddingResult = .success(anyData()),
        encryptWithTransportPublicRSAKeyResult: EncryptWithTransportPublicRSAKeyResult = .success(anyData()),
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: TestOTPEncrypter,
        spy: EncryptingSpy
    ) {
        let encryptingSpy = EncryptingSpy(
            encryptWithPaddingResult: encryptWithPaddingResult,
            encryptWithTransportPublicRSAKeyResult: encryptWithTransportPublicRSAKeyResult
        )
        let sut = TestOTPEncrypter(
            encryptWithPadding: encryptingSpy.encryptWithPadding,
            encryptWithTransportPublicRSAKey: encryptingSpy.encryptWithTransportPublicRSAKey
        )
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(encryptingSpy, file: file, line: line)
        
        return (sut, encryptingSpy)
    }
    
    private struct TestPrivateKey {
        
        let value: String
    }
    
    private typealias EncryptWithPaddingResult = Result<Data, Error>
    private typealias EncryptWithTransportPublicRSAKeyResult = Result<Data, Error>
    
    private final class EncryptingSpy {
        
        private(set) var encryptionCallCount = 0
        private let encryptWithPaddingResult: EncryptWithPaddingResult
        private let encryptWithTransportPublicRSAKeyResult: EncryptWithTransportPublicRSAKeyResult
        
        init(
            encryptWithPaddingResult: EncryptWithPaddingResult,
            encryptWithTransportPublicRSAKeyResult: EncryptWithTransportPublicRSAKeyResult
        ) {
            self.encryptWithPaddingResult = encryptWithPaddingResult
            self.encryptWithTransportPublicRSAKeyResult = encryptWithTransportPublicRSAKeyResult
        }
        
        func encryptWithPadding(
            _ string: String,
            with privateKey: TestPrivateKey
        ) throws -> Data {
            
            encryptionCallCount += 1
            return try encryptWithPaddingResult.get()
        }
        
        func encryptWithTransportPublicRSAKey(
            _ data: Data
        ) throws -> Data {
            
            encryptionCallCount += 1
            return try encryptWithTransportPublicRSAKeyResult.get()
        }
    }
    
    private func anyTestPrivateKey() -> TestPrivateKey {
        
        .init(value: "any TestPrivateKey")
    }
}
