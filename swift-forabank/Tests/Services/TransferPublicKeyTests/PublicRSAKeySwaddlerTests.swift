//
//  PublicRSAKeySwaddlerTests.swift
//  
//
//  Created by Igor Malyarov on 07.08.2023.
//

import TransferPublicKey
import XCTest

final class PublicRSAKeySwaddlerTests: XCTestCase {
    
    func test_init_shouldNotCallSaveKey() {
        
        let (_, spy, _) = makeSUT()
        
        XCTAssertEqual(spy.saveKeyCallCount, 0)
    }
    
    func test_init_shouldNotCallEncryption() {
        
        let (_, _, spy) = makeSUT()
        
        XCTAssertEqual(spy.generateRSA4096BitKeysCallCount, 0)
        XCTAssertEqual(spy.encryptOTPWithRSAKeyCallCount, 0)
        XCTAssertEqual(spy.aesEncrypt128bitChunksCallCount, 0)
    }
    
    func test_swaddle_shouldDeliverDataOnSuccessfulEncryptionAndKeySaving() throws {
        
        let sut = makeSUT().sut
        
        XCTAssertNoThrow(try sut.swaddleKey())
    }
    
    func test_swaddle_shouldDeliverSaveKeyErrorOnFailingStorage() throws {
        
        let saveError = anyError("save error")
        let (sut, _, _) = makeSUT(
            saveResult: .failure(saveError)
        )
        
        try XCTAssertThrowsAsNSError(
            sut.swaddleKey(),
            error: saveError
        )
    }
    
    func test_swaddle_shouldRetryAndDeliverGenerateKeysErrorOnFailingKeyGeneration() throws {
        
        let generateKeysError = anyError("generate keys error")
        let (sut, _, spy) = makeSUT(
            generateRSA4096BitKeysResults: [
                .failure(generateKeysError),
                .failure(generateKeysError)
            ])
        
        try XCTAssertThrowsAsNSError(
            sut.swaddleKey(),
            error: generateKeysError
        )
        XCTAssertEqual(spy.generateRSA4096BitKeysCallCount, 2)
    }
    
    func test_swaddle_shouldRetryOnFailingKeyGeneration() throws {
        
        let generateKeysError = anyError("generate keys error")
        let (sut, _, spy) = makeSUT(
            generateRSA4096BitKeysResults: [
                .failure(generateKeysError),
                success()
            ])
        
        try XCTAssertNoThrow(sut.swaddleKey())
        XCTAssertEqual(spy.generateRSA4096BitKeysCallCount, 2)
    }
    
    func test_swaddle_shouldDeliverEncryptOTPWithRSAKeyErrorFailingEncryption() throws {
        
        let encryptOTPWithRSAKeyError = anyError("encrypt OTP with RSA key error")
        let (sut, _, spy) = makeSUT(
            encryptOTPWithRSAKeyResults: [
                .failure(encryptOTPWithRSAKeyError),
                .failure(encryptOTPWithRSAKeyError)
            ])
        
        try XCTAssertThrowsAsNSError(
            sut.swaddleKey(),
            error: encryptOTPWithRSAKeyError
        )
        XCTAssertEqual(spy.encryptOTPWithRSAKeyCallCount, 2)
    }
    
    func test_swaddle_shouldRetryEncryptOTPWithRSAKeyErrorFailingEncryption() throws {
        
        let encryptOTPWithRSAKeyError = anyError("encrypt OTP with RSA key error")
        let (sut, _, spy) = makeSUT(
            encryptOTPWithRSAKeyResults: [
                .failure(encryptOTPWithRSAKeyError),
                success()
            ])
        
        try XCTAssertNoThrow(sut.swaddleKey())
        XCTAssertEqual(spy.encryptOTPWithRSAKeyCallCount, 2)
    }
    
    func test_swaddle_shouldDeliverAESEncrypt128bitChunksErrorFailingEncryption() throws {
        
        let aesEncrypt128bitChunks = anyError("AES encrypt 128 bit chunks error")
        let (sut, _, _) = makeSUT(
            aesEncrypt128bitChunksResult: .failure(aesEncrypt128bitChunks)
        )
        
        try XCTAssertThrowsAsNSError(
            sut.swaddleKey(),
            error: aesEncrypt128bitChunks
        )
    }
    
    // MARK: - Helpers
    
    fileprivate typealias SUT = PublicRSAKeySwaddler<TestOTP, TestPrivateKey, TestPublicKey>
    
    private func makeSUT(
        generateRSA4096BitKeysResults: [GenerateRSA4096BitKeysResult] = [success(), success()],
        encryptOTPWithRSAKeyResults: [EncryptOTPWithRSAKeyResult] = [success()],
        aesEncrypt128bitChunksResult: AESEncrypt128bitChunksResult = success(),
        saveResult: SaveResult = success(),
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        keyStorageSpy: KeyStorageSpy,
        swaddlerSpy: SwaddlerSpy
    ) {
        let keyStorageSpy = KeyStorageSpy(saveResult: saveResult)
        let swaddlerSpy = SwaddlerSpy(
            generateRSA4096BitKeysResults: generateRSA4096BitKeysResults,
            encryptOTPWithRSAKeyResults: encryptOTPWithRSAKeyResults,
            aesEncrypt128bitChunksResult: aesEncrypt128bitChunksResult
        )
        
        let sut = SUT(
            generateRSA4096BitKeys: swaddlerSpy.generateRSA4096BitKeys,
            signEncryptOTP: swaddlerSpy.encryptOTPWithRSAKey,
            saveKeys: keyStorageSpy.saveKeys,
            x509Representation: { $0.rawRepresentation },
            aesEncrypt128bitChunks: swaddlerSpy.aesEncrypt128bitChunks
        )
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(keyStorageSpy, file: file, line: line)
        trackForMemoryLeaks(swaddlerSpy, file: file, line: line)
        
        return (sut, keyStorageSpy, swaddlerSpy)
    }
    
    fileprivate struct TestPrivateKey {
        
        let value: String
    }
    
    fileprivate struct TestPublicKey {
        
        let value: String
        
        var rawRepresentation: Data { value.data(using: .utf8)! }
    }
    
    fileprivate final class SwaddlerSpy {
        
        typealias GenerateRSA4096BitKeysResult = Result<(TestPrivateKey, TestPublicKey), Error>
        typealias EncryptOTPWithRSAKeyResult = Result<Data, Error>
        typealias AESEncrypt128bitChunksResult = Result<Data, Error>
        
        private(set) var generateRSA4096BitKeysCallCount = 0
        private(set) var encryptOTPWithRSAKeyCallCount = 0
        private(set) var aesEncrypt128bitChunksCallCount = 0
        
        private var generateRSA4096BitKeysResults: [GenerateRSA4096BitKeysResult]
        private var encryptOTPWithRSAKeyResults: [EncryptOTPWithRSAKeyResult]
        private let aesEncrypt128bitChunksResult: AESEncrypt128bitChunksResult
        
        init(
            generateRSA4096BitKeysResults: [GenerateRSA4096BitKeysResult],
            encryptOTPWithRSAKeyResults: [EncryptOTPWithRSAKeyResult],
            aesEncrypt128bitChunksResult: AESEncrypt128bitChunksResult
        ) {
            self.generateRSA4096BitKeysResults = generateRSA4096BitKeysResults
            self.encryptOTPWithRSAKeyResults = encryptOTPWithRSAKeyResults
            self.aesEncrypt128bitChunksResult = aesEncrypt128bitChunksResult
        }
        
        func generateRSA4096BitKeys(
        ) throws -> (TestPrivateKey, TestPublicKey) {
            
            generateRSA4096BitKeysCallCount += 1
            return try generateRSA4096BitKeysResults.removeFirst().get()
        }
        
        func encryptOTPWithRSAKey(
            _ otp: TestOTP,
            _ privateKey: TestPrivateKey
        ) throws -> Data {
            
            encryptOTPWithRSAKeyCallCount += 1
            return try encryptOTPWithRSAKeyResults.removeFirst().get()
        }
        
        typealias SharedSecret = SwaddleKeyDomain<TestOTP>.SharedSecret
        
        func aesEncrypt128bitChunks(
            _ data: Data,
            sharedSecret: SharedSecret
        ) throws -> Data {
            
            aesEncrypt128bitChunksCallCount += 1
            return try aesEncrypt128bitChunksResult.get()
        }
    }
    
    fileprivate final class KeyStorageSpy {
        
        typealias SaveResult = Result<Void, Error>
        
        private(set) var saveKeyCallCount = 0
        
        private let saveResult: SaveResult
        
        init(saveResult: SaveResult) {
            
            self.saveResult = saveResult
        }
        
        func saveKeys(
            _ privateKey: TestPrivateKey,
            _ publicKey: TestPublicKey
        ) throws -> Void {
            
            saveKeyCallCount += 1
            return try saveResult.get()
        }
    }
}

private typealias SwaddlerSpy = PublicRSAKeySwaddlerTests.SwaddlerSpy
private typealias GenerateRSA4096BitKeysResult = SwaddlerSpy.GenerateRSA4096BitKeysResult
private typealias EncryptOTPWithRSAKeyResult = SwaddlerSpy.EncryptOTPWithRSAKeyResult
private typealias AESEncrypt128bitChunksResult = SwaddlerSpy.AESEncrypt128bitChunksResult

private typealias SaveResult = PublicRSAKeySwaddlerTests.KeyStorageSpy.SaveResult

private func success() -> GenerateRSA4096BitKeysResult {
    
    .success((.init(value: "private"), .init(value: "public")))
}

private func success() -> EncryptOTPWithRSAKeyResult {
    
    .success(anyData())
}

private func success() -> SaveResult {
    
    .success(())
}

private func failure(_ message: String = "save key error") -> SaveResult {
    
    .failure(anyError(message))
}

private func failure() -> EncryptOTPWithRSAKeyResult {
    
    .failure(anyError())
}

private func anyOTP(_ value: String = "any OTP") -> TestOTP {
    
    .init(value: value)
}

// MARK: - DSL

private extension PublicRSAKeySwaddlerTests.SUT {
    
    func swaddleKey() throws -> Data {
        
        try self.swaddleKey(with: anyOTP(), and: anySharedSecret())
    }
}
