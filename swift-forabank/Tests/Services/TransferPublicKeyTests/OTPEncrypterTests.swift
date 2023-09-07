//
//  OTPEncrypterTests.swift
//  
//
//  Created by Igor Malyarov on 07.08.2023.
//

import TransferPublicKey
import XCTest

final class OTPEncrypterTests: XCTestCase {
    
    func test_init_shouldNotCallEncryption() throws {
        
        let (_, spy) = makeSUT()
        
        XCTAssertEqual(spy.encryptionCallCount, 0)
    }
    
    func test_encrypt_shouldFailOnEncryptWithPaddingError() throws {
        
        let (otp, privateRSAKey) = makeOTPAndKey()
        let signWithPaddingError = anyError("signWithPaddingError")
        let (sut, _) = makeSUT(
            signWithPaddingResult: .failure(signWithPaddingError)
        )
        
        try XCTAssertThrowsAsNSError(
            sut.encrypt(otp, withRSAKey: privateRSAKey),
            error: signWithPaddingError)
    }
    
    func test_encrypt_shouldFailOnEncryptWithTransportPublicRSAKeyError() throws {
        
        let (otp, privateRSAKey) = makeOTPAndKey()
        let encryptWithTransportPublicRSAKeyError = anyError("encryptWithTransportPublicRSAKeyError")
        let (sut, _) = makeSUT(
            signWithPaddingResult: .success(anyData()),
            encryptWithTransportPublicRSAKeyResult: .failure(encryptWithTransportPublicRSAKeyError)
        )
        
        try XCTAssertThrowsAsNSError(
            sut.encrypt(otp, withRSAKey: privateRSAKey),
            error: encryptWithTransportPublicRSAKeyError
        )
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
    
    private typealias TestOTPEncrypter = OTPEncrypter<TestOTP, TestPrivateKey>
    
    private func makeOTPAndKey() -> (TestOTP, TestPrivateKey) {
        
        let otp = TestOTP(value: "any OTP")
        let privateRSAKey = anyTestPrivateKey()
        
        return (otp, privateRSAKey)
    }
    
    private func makeSUT(
        signWithPaddingResult: EncryptWithPaddingResult = .success(anyData()),
        encryptWithTransportPublicRSAKeyResult: EncryptWithTransportPublicRSAKeyResult = .success(anyData()),
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: TestOTPEncrypter,
        spy: EncryptingSpy
    ) {
        let encryptingSpy = EncryptingSpy(
            signWithPaddingResult: signWithPaddingResult,
            encryptWithTransportPublicRSAKeyResult: encryptWithTransportPublicRSAKeyResult
        )
        let sut = TestOTPEncrypter(
            signWithPadding: encryptingSpy.signWithPadding,
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
        private let signWithPaddingResult: EncryptWithPaddingResult
        private let encryptWithTransportPublicRSAKeyResult: EncryptWithTransportPublicRSAKeyResult
        
        init(
            signWithPaddingResult: EncryptWithPaddingResult,
            encryptWithTransportPublicRSAKeyResult: EncryptWithTransportPublicRSAKeyResult
        ) {
            self.signWithPaddingResult = signWithPaddingResult
            self.encryptWithTransportPublicRSAKeyResult = encryptWithTransportPublicRSAKeyResult
        }
        
        func signWithPadding(
            _ otp: TestOTP,
            with privateKey: TestPrivateKey
        ) throws -> Data {
            
            encryptionCallCount += 1
            return try signWithPaddingResult.get()
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
