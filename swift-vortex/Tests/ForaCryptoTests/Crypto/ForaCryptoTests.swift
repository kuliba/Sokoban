//
//  ForaCryptoTests.swift
//  
//
//  Created by Igor Malyarov on 10.08.2023.
//

import CryptoKit
import ForaCrypto
import XCTest

final class ForaCryptoTests: XCTestCase {
    
    func test_transportPublicKey_shouldSupportRSAAlgorithmsForEncryptionAndDecryption() throws {
        
        let key = try transportPublicKey()
        
        rsaAlgorithms.forEach {
            
            expectIsSupported(key, .encrypt, $0)
            expectIsSupported(key, .decrypt, $0)
        }
    }
    
    func test_strings_shouldBeBase64EncodedData() throws {
        
        try strings.forEach {
            
            try XCTAssertNoThrow(XCTUnwrap(Data(
                base64Encoded: $0,
                options: .ignoreUnknownCharacters
            )))
        }
        
        try encryptedDecryptedStrings.forEach {
            
            try XCTAssertNoThrow(XCTUnwrap(Data(
                base64Encoded: $0.encrypted,
                options: .ignoreUnknownCharacters
            )))
            try XCTAssertNoThrow(XCTUnwrap(Data(
                base64Encoded: $0.decrypted,
                options: .ignoreUnknownCharacters
            )))
        }
    }
    
    func test_decrypt384PublicKey_shouldDecryptKeysFromKnownStrings() throws {
        
        let advancedByAmount = 416
        
        try encryptedDecryptedStrings.forEach { string in
            
            try XCTAssertNoThrow(
                Crypto.decrypt384PublicKey(
                    from: string.encrypted,
                    with: transportPublicKey(),
                    advancedBy: advancedByAmount
                ),
                "Key decryption failed for \(string)"
            )
        }
    }
    
    func test_transportDecrypt_shouldDecryptKeysFromKnownStrings() throws {
        
        try encryptedDecryptedStrings.forEach {
            
            try XCTAssertNoThrow(Crypto.transportDecryptP384PublicKey($0.encrypted))
        }
    }
    
    func test_transportDecrypt_shouldDecryptEncryptedStringsWithDropFirst392() throws {
        
        for string in encryptedDecryptedStrings {
            
            let data = try Crypto.transportDecrypt(string.encrypted)
            
            for amount in 0..<data.count - 1 {
                
                let rawBase64Encoded = data.dropFirst(amount).base64EncodedString()
                
                switch amount {
                case 392:
                    XCTAssertEqual(
                        rawBase64Encoded,
                        string.decrypted,
                        "Failed for amount: \(amount)."
                    )
                    
                default:
                    XCTAssertNotEqual(
                        rawBase64Encoded,
                        string.decrypted,
                        "Failed for amount: \(amount)."
                    )
                }
            }
        }
    }
    
    func test_shouldMakeKeyWithRepresentationAdvancedBy() throws {
        
        try encryptedDecryptedStrings.forEach {
            
            let decryptedData = try Crypto.transportDecrypt($0.encrypted)
            
            try p384PublicKeyFactories.forEach { factory in
                for first in 0..<decryptedData.count {
                    
                    try expectRepresentationAdvancedBy(
                        decryptedData: decryptedData,
                        droppingFirst: first,
                        factory: factory
                    )
                }
            }
        }
    }
    
    // MARK: comment failure test(failure on release_9_5)
//    func test_P384PrivateKey_rom() throws {
//
//        let strings: [String] = [
//            .privateKeyBase64String_rom,
//            .privateKeyBase64String_rom4,
//        ]
//
//        try strings.forEach { string in
//            try p384PrivateKeyFactories.forEach { factory in
//
//                let base64 = try XCTUnwrap(Data(base64Encoded: string))
//
//                for first in 0..<base64.count {
//
//                    try expectKey(with: factory, from: base64, droppingFirst: first)
//                }
//            }
//        }
//    }
    
    func test_P384PrivateKeyDerRepresentation() throws {
        
        let base64: String = .privateKeyP384DerRepresentationBase64String
        let data = try XCTUnwrap(Data(base64Encoded: base64))
        let privateKey = try P384.KeyAgreement.PrivateKey(derRepresentation: data)
        
        XCTAssertEqual(privateKey.derRepresentation, data)
        XCTAssertEqual(privateKey.derRepresentation.base64EncodedString(), base64)
    }
    
    func test_P384PrivateKeyRawRepresentation() throws {
        
        let base64: String = .privateKeyP384RawRepresentationBase64String
        let data = try XCTUnwrap(Data(base64Encoded: base64))
        let privateKey = try P384.KeyAgreement.PrivateKey(rawRepresentation: data)
        
        XCTAssertEqual(privateKey.rawRepresentation, data)
        XCTAssertEqual(privateKey.rawRepresentation.base64EncodedString(), base64)
    }
    
    func test_derivedSharedSecret() throws {
        
        let privateKey = try Crypto.makeP384PrivateKey(
            from: .privateKeyP384DerRepresentationBase64String
        )
        let publicKey = try Crypto.transportDecryptP384PublicKey(
            from: .serverPublicKeyEncryptedString_rom4
        )
        
        let sharedSecret = try privateKey.sharedSecretFromKeyAgreement(with: publicKey)
        
        let sharedSecretData = sharedSecret.data
        let sharedSecretBase64 = sharedSecretData.base64EncodedString()
        XCTAssertEqual(sharedSecretBase64, "HCbQ8gXbvsIDk8TdeTXhOr3U38zcmIZ9kfHPN59hBbY/v8Qq0YlV/g0sAXTWEE+9")
    }
    
    func test_sharedSecret_rom() throws {
        
        let privateKeyBase64Strings: [String] = [
            .privateKeyBase64String_rom4,
            .privateKeyBase64String_rom5,
        ]
        let serverPublicKeyEncryptedStrings: [String] = [
            .serverPublicKeyEncryptedString_rom4,
            .serverPublicKeyEncryptedString_rom5,
        ]
        let sharedSecretBase64Strings: [String] = [
            .sharedSecretBase64String_rom4,
            .sharedSecretBase64String_rom5,
        ]
        
        try zip(
            zip(privateKeyBase64Strings, serverPublicKeyEncryptedStrings),
            sharedSecretBase64Strings
        )
        .enumerated()
        .forEach { _, element in
            
            let privateKey = try Crypto.makeP384PrivateKey(
                from: element.0.0
            )
            let publicKey = try Crypto.transportDecryptP384PublicKey(
                from: element.0.1
            )
            let sharedSecret = try Crypto.sharedSecret(
                privateKey: privateKey,
                publicKey: publicKey
            )
            
            XCTAssertEqual(sharedSecret.count, 48)
            XCTAssertEqual(sharedSecret.base64EncodedString(), element.1)
        }
    }
    
    /*
     keeping failing test as facilitator for future explorations
     
    func test_makeP384SymmetricKey_rom6() throws {
        
        let privateKey = try Crypto.makeP384PrivateKey(
            from: .privateKeyBase64String_rom6
        )
        let publicKey = try Crypto.transportDecryptP384PublicKey(
            from: .serverPublicKeyEncryptedString_rom6
        )
        let symmetricKey = try Crypto.makeP384SymmetricKey(
            privateKey: privateKey,
            publicKey: publicKey,
            protocolSalt: Data(base64Encoded: "AiiOSnOTmhje0BiyPokToA==")!,
            sharedInfo: Data()//Data(base64Encoded: "AiiOSnOTmhje0BiyPokToA==")!
//            sharedInfo: Data(base64Encoded: "2/7L/hjLEfkfYmOvwJKGhA==")!
        )
        
        XCTAssertEqual(symmetricKey.count, 32)
        XCTAssertEqual(
            symmetricKey.base64EncodedString(),
            .symmetricKeyBase64String_rom6
        )
    }
    */
    
    func test_sharedSecret_trimming_rom6() throws {
        
        let privateKey = try Crypto.makeP384PrivateKey(
            from: .privateKeyBase64String_rom6
        )
        let publicKey = try Crypto.transportDecryptP384PublicKey(
            from: .serverPublicKeyEncryptedString_rom6
        )
        let sharedSecret = try Crypto.sharedSecret(
            privateKey: privateKey,
            publicKey: publicKey
        )
        
        XCTAssertEqual(sharedSecret.count, 48)
        XCTAssertEqual(sharedSecret.base64EncodedString(), .sharedSecretBase64String_rom6)
        
        let trimmed = sharedSecret.dropLast(16)
        XCTAssertEqual(trimmed.count, 32)
        XCTAssertEqual(trimmed.base64EncodedString(), .symmetricKeyBase64String_rom6)
    }
    
    /*
     keeping failing test as facilitator for future explorations
     
    func test_makeP384SymmetricKey_________() throws {
        
        let sample = try XCTUnwrap(samples["rom6"])
        let (privateKey, publicKey) = try keysFrom(sample: sample)
        
        let hashFunctions: [any HashFunction.Type] = [
            SHA256.self, SHA384.self, SHA512.self
        ]
        let dataSamples: [Data] = try [
            .init(),
            "CryptoKit Key Agreement".data(using: .utf8),
            SymmetricKey(size: .bits128).data,
            SymmetricKey(size: .bits256).data,
            .init(base64Encoded: "AiiOSnOTmhje0BiyPokToA=="), // Rom: SecureRandom().nextBytes(iv)
            .init(base64Encoded: "2/7L/hjLEfkfYmOvwJKGhA=="), // Rom: iv
        ].map { try XCTUnwrap($0) }
        
        XCTAssertEqual(dataSamples.map(\.count), [0, 23, 16, 32, 16, 16])
        
        let sharedSecret = try privateKey.sharedSecretFromKeyAgreement(with: publicKey)
        
        try XCTAssertEqual(
            sharedSecret.data,
            sample.sharedSecretData
        )
        
        hashFunctions.forEach { hashFunction in
            dataSamples.forEach { protocolSalt in
                dataSamples.forEach { sharedInfo in
                    
                    let x963DerivedSymmetricKey = sharedSecret.x963DerivedSymmetricKey(
                        using: hashFunction,
                        sharedInfo: sharedInfo,
                        outputByteCount: 32
                    )
                    XCTAssertEqual(
                        x963DerivedSymmetricKey.data.base64EncodedString(),
                        sample.symmetricKeyBase64String
                    )
                    XCTAssertNotEqual(
                        x963DerivedSymmetricKey.data.base64EncodedString(),
                        sample.symmetricKeyBase64String
                    )
                    
                    let hkdfDerivedSymmetricKey = sharedSecret.hkdfDerivedSymmetricKey(
                        using: hashFunction,
                        salt: protocolSalt,
                        sharedInfo: sharedInfo,
                        outputByteCount: 32
                    )
                    XCTAssertEqual(
                        hkdfDerivedSymmetricKey.data.base64EncodedString(),
                        sample.symmetricKeyBase64String
                    )
                    XCTAssertNotEqual(
                        hkdfDerivedSymmetricKey.data.base64EncodedString(),
                        sample.symmetricKeyBase64String
                    )
                }
            }
        }
    }
    
    private func keysFrom(
        sample: Sample,
        file: StaticString = #file,
        line: UInt = #line
    ) throws -> (
        privateKey: P384.KeyAgreement.PrivateKey,
        publicKey: P384.KeyAgreement.PublicKey
    ) {
        let privateKey = try Crypto.makeP384PrivateKey(
            from: .privateKeyBase64String_rom6
        )
        let publicKey = try Crypto.transportDecryptP384PublicKey(
            from: .serverPublicKeyEncryptedString_rom6
        )
        
        return (privateKey, publicKey)
    }
    
    private struct Sample {
        
        let privateKeyBase64String: String
        let serverPublicKeyEncryptedString: String
        let sharedSecretBase64String: String
        let symmetricKeyBase64String: String
        
        var sharedSecretData: Data {
            get throws {
                try XCTUnwrap(Data(base64Encoded: sharedSecretBase64String))
            }
        }
    }
    
    private let samples: [String: Sample] = [
        
        "rom6": .init(
            privateKeyBase64String: .privateKeyBase64String_rom6,
            serverPublicKeyEncryptedString: .serverPublicKeyEncryptedString_rom6,
            sharedSecretBase64String: .sharedSecretBase64String_rom6,
            symmetricKeyBase64String: .symmetricKeyBase64String_rom6
        ),
    ]
     */
    
    func test_decrypt384PublicKey_shouldNotFailForSelectedParameters() throws {
        
        for string in strings {
            for amount in 0..<512 {
                
                switch amount {
                    
                case 416:
                    try XCTAssertNoThrow(
                        Crypto.decrypt384PublicKey(
                            from: string,
                            with: transportPublicKey(),
                            advancedBy: amount
                        ),
                        "\nFailure with amount:\(amount) with string \"\(string)\""
                    )
                    
                default:
                    try XCTAssertThrowsError(
                        Crypto.decrypt384PublicKey(
                            from: string,
                            with: transportPublicKey(),
                            advancedBy: amount
                        ),
                        "\nExpected failure with amount:\(amount) with string \"\(string)\""
                    )
                }
            }
        }
    }
    
    func test_decryptPublicKey_shouldNotFailForSelectedParameters() throws {
        
        let keyTypes: [Crypto.KeyType] = [
            .ec,
            .ecsecPrimeRandom,
            .rsa,
        ]
        
        for string in strings {
            for algorithm in rsaAlgorithms {
                for keyType in keyTypes {
                    // MARK: to find options change amount range
                    // for amount in 0..<512 {
                    for amount in 414..<416 {
                        
                        switch (algorithm, keyType, amount) {
                            
                        case (.rsaEncryptionRaw, .ec, 415),
                            (.rsaEncryptionRaw, .ecsecPrimeRandom, 415):
                            try XCTAssertNoThrow(
                                Crypto.decryptPublicKey(
                                    from: string,
                                    with: transportPublicKey(),
                                    decryptionAlgorithm: algorithm,
                                    keyType: keyType,
                                    advancedBy: amount
                                ),
                                "\nFailure with \(algorithm) keyType: \(keyType) amount:\(amount) with string \"\(string)\""
                            )
                            
                        default:
                            try XCTAssertThrowsError(
                                Crypto.decryptPublicKey(
                                    from: string,
                                    with: transportPublicKey(),
                                    decryptionAlgorithm: algorithm,
                                    keyType: keyType,
                                    advancedBy: amount
                                ),
                                "\nExpected failure with \(algorithm) keyType: \(keyType) amount:\(amount) with string \"\(string)\""
                            )
                        }
                    }
                }
            }
        }
    }
    
    func test_hkdfDeriveSymmetricKey_shouldMakeSymmetricKeysFromKnownStrings() throws {
        
        let advancedByAmount = 416
        
        try strings.forEach { string in
            
            let publicKey = try Crypto.decrypt384PublicKey(
                from: string,
                with: transportPublicKey(),
                advancedBy: advancedByAmount
            )
            let privateKey = anyP384PrivateKey()
            
            try XCTAssertNoThrow(
                Crypto.hkdfDeriveSymmetricKey(
                    privateKey: privateKey,
                    publicKey: publicKey
                ),
                "SymmetricKey creation failed for \(string)"
            )
        }
    }
    
    func test_x963DeriveSymmetricKey_shouldMakeSymmetricKeysFromKnownStrings() throws {
        
        let advancedByAmount = 416
        
        try strings.forEach { string in
            
            let publicKey = try Crypto.decrypt384PublicKey(
                from: string,
                with: transportPublicKey(),
                advancedBy: advancedByAmount
            )
            let privateKey = anyP384PrivateKey()
            
            try XCTAssertNoThrow(
                Crypto.x963DeriveSymmetricKey(
                    privateKey: privateKey,
                    publicKey: publicKey
                ),
                "SymmetricKey creation failed for \(string)"
            )
        }
    }
    
    func test_privateKeyLength() {
        
        XCTAssertEqual(
            String.privateKeyP384DerRepresentationBase64String.count,
            248
        )
        try XCTAssertEqual(
            XCTUnwrap(Data(base64Encoded: .privateKeyP384DerRepresentationBase64String)).count,
            185
        )
        
        XCTAssertEqual(
            String.privateKeyBase64String_rom.count,
            260
        )
        try XCTAssertEqual(
            XCTUnwrap(Data(base64Encoded: .privateKeyBase64String_rom)).count,
            194
        )
        XCTAssertEqual(
            String.privateKeyBase64String_rom4.count,
            260
        )
        try XCTAssertEqual(
            XCTUnwrap(Data(base64Encoded: .privateKeyBase64String_rom4)).count,
            194
        )
    }
    
    func test_keyRawRepresentationSizes () throws {
        
        let privateKey = P384.KeyAgreement.PrivateKey()
        XCTAssertEqual(privateKey.rawRepresentation.count, 48)
        
        let publicKey = privateKey.publicKey
        let publicKeyRaw = publicKey.rawRepresentation
        XCTAssertEqual(publicKeyRaw.count, 96)
        let base64String = publicKeyRaw.base64EncodedString()
        
        XCTAssertEqual(base64String.count, 128)
        XCTAssertEqual(String.serverPublicKeyDecryptedString_rom.count, 160)
        
        let raw = try XCTUnwrap(Data(base64Encoded: base64String))
        XCTAssertEqual(publicKeyRaw, raw)
        XCTAssertEqual(raw.count, 96)
        XCTAssertNoThrow(try P384.KeyAgreement.PublicKey(rawRepresentation: raw))
    }
    
    func test_createRandomSecKeys_shouldNotFailFor4096RSA() throws {
        
        try XCTAssertNoThrow(createRandom4096RSAKeys())
    }
    
    func test_keyBockSize() throws {
        
        let (privateKey, publicKey) = try createRandom4096RSAKeys()
        
        XCTAssertEqual(SecKeyGetBlockSize(privateKey), 512)
        XCTAssertEqual(SecKeyGetBlockSize(publicKey), 512)
    }
    
    func test_privateRSAKey_shouldSupportSigning() throws {
        
        let (privateKey, _) = try createRandom4096RSAKeys()
        
        let algorithms: [SecKeyAlgorithm] = [
            .rsaSignatureRaw,
            .rsaSignatureDigestPSSSHA1,
            .rsaSignatureDigestPSSSHA224,
            .rsaSignatureDigestPSSSHA256,
            .rsaSignatureDigestPSSSHA384,
            .rsaSignatureDigestPSSSHA512,
            .rsaSignatureMessagePSSSHA1
        ]
        
        algorithms.forEach {
            
            expectIsSupported(privateKey, .sign, $0)
        }
    }
    
    func test_RSASigningWithPrivateKey() throws {
        
        let (privateKey, _) = try createRandom4096RSAKeys()
        let message = "important message"
        let data = try XCTUnwrap(message.data(using: .utf8))
        
        let signed = try Crypto.sign(
            data,
            withPrivateKey: privateKey,
            algorithm: .rsaSignatureDigestPKCS1v15SHA256
        )
        XCTAssertEqual(signed.count, 512)
    }
    
    func test_RSAEncryption_publicKey_privateKey() throws {
        
        let (privateKey, publicKey) = try createRandom4096RSAKeys()
        let message = "important message"
        let data = try XCTUnwrap(message.data(using: .utf8))
        
        let encrypted = try Crypto.encrypt(
            data: data,
            withPublicKey: publicKey,
            algorithm: .rsaEncryptionPKCS1
        )
        XCTAssertEqual(encrypted.count, 512)
        
        let decrypted = try Crypto.rsaPKCS1Decrypt(data: encrypted, withPrivateKey: privateKey)
        
        let decryptedMessage = String(data: decrypted, encoding: .utf8)
        XCTAssertEqual(message.count, 17)
        XCTAssertEqual(decryptedMessage?.count, 17)
        XCTAssertEqual(decryptedMessage, message)
    }
    
    func test_RSAEncryption_shouldThrowOnPrivateKey() throws {
        
        let (privateKey, _) = try createRandom4096RSAKeys()
        
        try XCTAssertThrowsError(
            Crypto.encrypt(
                data: anyData(),
                withPublicKey: privateKey,
                algorithm: .rsaEncryptionPKCS1
            )
        )
    }
    
    func test_encrypt_shouldFailOnPublicKey() throws {
        
        let (_, publicKey) = try createRandom4096RSAKeys()
        
        try XCTAssertThrowsError(
            Crypto.encrypt(anyData(), with: publicKey)
        )
    }
    
    /* keep this test for future explorations
     
    func test_privateKey_publicKey() throws {
        
        let (privateKey, publicKey) = try createRandom4096RSAKeys()
        let message = "important message"
        let data = try XCTUnwrap(message.data(using: .utf8))
        
        let encrypted = try Crypto.encrypt(data, with: privateKey)
        XCTAssertEqual(encrypted.count, 512)
        
        let decr = try Crypto.decrypt(encrypted, using: .rsaEncryptionRaw, secKey: publicKey)
        let decrMessage = String(data: decr, encoding: .utf8)
        XCTAssertEqual(decrMessage, "")
        XCTAssertEqual(decrMessage?.count, 17)
        
        let decrypted = try Crypto.decrypt(encrypted, with: publicKey)
        XCTAssertEqual(decrypted.count, 512)
        
        let decryptedMessage = String(data: decrypted, encoding: .utf8)
        XCTAssertEqual(message.count, 17)
        XCTAssertEqual(decryptedMessage?.count, 17)
        XCTAssertEqual(decryptedMessage, message)
    }
    */
    
    func test_encryptWithRSAKey_shouldEncryptWithPublicKey() throws {
        
        let (_, publicKey) = try createRandom4096RSAKeys()
        let message = try XCTUnwrap("important message".data(using: .utf8))
        
        // also try OAEP, etc
        let encrypted = try Crypto.encryptWithRSAKey(message, publicKey: publicKey, padding: .PKCS1)
        
        XCTAssertNotNil(encrypted)
        XCTAssertEqual(encrypted.count, 512)
    }
    
    func test_encryptWithRSAKey_shouldEncryptDecryptable() throws {
        
        let (privateKey, publicKey) = try createRandom4096RSAKeys()
        let message = try XCTUnwrap("important message".data(using: .utf8))
        
        // also try OAEP, etc
        let encrypted = try Crypto.encryptWithRSAKey(message, publicKey: publicKey, padding: .PKCS1)
        let decrypted = try Crypto.decrypt(encrypted, using: .rsaEncryptionPKCS1, secKey: privateKey)
        
        XCTAssertNoDiff(decrypted, message)
    }
    
    func test_encryptWithRSAKey_shouldFailToEncryptWithPrivateKey() throws {
        
        let (privateKey, _) = try createRandom4096RSAKeys()
        let message = try XCTUnwrap("important message".data(using: .utf8))
        
        // also try OAEP, etc
        try XCTAssertThrowsAsNSError(
            Crypto.encryptWithRSAKey(message, publicKey: privateKey, padding: .PKCS1),
            error: Crypto.Error.encryptionFailed()
        )
    }
    
    func test_rsaPKCS1Encrypt_shouldEncryptData() throws {
        
        let publicKey = try createRandom4096RSAKeys().publicKey
        let data = try XCTUnwrap("some data".data(using: .utf8))
        
        let encrypted = try Crypto.rsaPKCS1Encrypt(
            data: data,
            withPublicKey: publicKey
        )
        
        XCTAssertNotEqual(encrypted, data)
    }
    
    func test_rsaPKCS1Decrypt_shouldDecryptEncryptedData() throws {
        
        let originalMessage = "some data"
        let data = try XCTUnwrap(originalMessage.data(using: .utf8))
        let (privateKey, publicKey) = try createRandom4096RSAKeys()
        
        let encrypted = try Crypto.rsaPKCS1Encrypt(
            data: data,
            withPublicKey: publicKey
        )
        let decrypted = try Crypto.rsaPKCS1Decrypt(data: encrypted, withPrivateKey: privateKey)
        let decryptedMessage = try XCTUnwrap(String(data: decrypted, encoding: .utf8))
        
        XCTAssertEqual(originalMessage, decryptedMessage)
    }
    
    // MARK: - Helpers Tests
    
    func test_createRandom4096RSAKeys_shouldCreatePublicKeyForRSAEncryptionPKCS1() throws {
        
        let publicKey = try createRandom4096RSAKeys().publicKey
        let rsaEncryptionPKCS1 = SecKeyIsAlgorithmSupported(publicKey, .encrypt, .rsaEncryptionPKCS1)
        
        XCTAssertTrue(rsaEncryptionPKCS1)
    }
    
    // MARK: - Helpers
        
    private func keyData() throws -> Data {
        
        let keyBase64 = "MHYwEAYHKoZIzj0CAQYFK4EEACIDYgAEFZp5pRhs5snqQLa5AsGGtPKvaFfxF3CgSDMKCmwCAKmeZtKetmdUAq/UrfFjP7k7rbH+QSLisR/g3XHFVwQY/CSbuqII5i5Adh2ssCtYmQ7oDbvmk9PbeyCZE4twlNtV"
        
        return try XCTUnwrap(Data(base64Encoded: keyBase64))
    }

    
    private typealias MakePrivateKey = (Data) throws -> P384.KeyAgreement.PrivateKey
    private typealias PrivateKeyFactory = (param: String, makeKey: MakePrivateKey)
    
    private typealias MakePublicKey = (Data) throws -> P384.KeyAgreement.PublicKey
    private typealias PublicKeyFactory = (param: String, makeKey: MakePublicKey)
    
    private let p384PublicKeyFactories: [PublicKeyFactory] = [
        ("rawRepresentation", P384.KeyAgreement.PublicKey.init(rawRepresentation:)),
        ("derRepresentation", P384.KeyAgreement.PublicKey.init(derRepresentation:)),
        ("x963Representation", P384.KeyAgreement.PublicKey.init(x963Representation:)),
    ]
    
    private let p384PrivateKeyFactories: [PrivateKeyFactory] = [
        ("rawRepresentation", P384.KeyAgreement.PrivateKey.init(rawRepresentation:)),
        ("derRepresentation", P384.KeyAgreement.PrivateKey.init(derRepresentation:)),
        ("x963Representation", P384.KeyAgreement.PrivateKey.init(x963Representation:)),
    ]
    
    private func expectRepresentationAdvancedBy(
        decryptedData: Data,
        droppingFirst first: Int,
        factory: PublicKeyFactory,
        file: StaticString = #file,
        line: UInt = #line
    ) throws {
        
        let data = decryptedData.dropFirst(first)
        
        switch (first, factory.param) {
        case (392, "derRepresentation"):
            try XCTAssertNoThrow(
                factory.makeKey(data),
                "Failed for \(factory.param), drop first \(first)",
                file: file, line: line
            )
            
        case (415, "x963Representation"):
            try XCTAssertNoThrow(
                factory.makeKey(data),
                "Failed for \(factory.param), drop first \(first)",
                file: file, line: line
            )
            
        case (416, "rawRepresentation"):
            try XCTAssertNoThrow(
                factory.makeKey(data),
                "Failed for \(factory.param), drop first \(first)",
                file: file, line: line
            )
            
            
        default:
            try XCTAssertThrowsError(
                factory.makeKey(data),
                "Failed for \(factory.param), drop first \(first)",
                file: file, line: line
            )
        }
    }
    
    private func expectKey(
        with factory: PrivateKeyFactory,
        from data: Data,
        droppingFirst first: Int,
        file: StaticString = #file,
        line: UInt = #line
    ) throws {
        
        let data = data.dropFirst(first)
        
        switch (first, factory.param) {
        case (0, "derRepresentation"),
            (27, "derRepresentation"):
            try XCTAssertNoThrow(
                factory.makeKey(data),
                "Failed for \(factory.param), drop first \(first)",
                file: file, line: line
            )
            
        case (146, "rawRepresentation"):
            try XCTAssertNoThrow(
                factory.makeKey(data),
                "Failed for \(factory.param), drop first \(first)",
                file: file, line: line
            )
            
        default:
            try XCTAssertThrowsError(
                factory.makeKey(data),
                "Failed for \(factory.param), drop first \(first)"
            )
        }
    }
    
    private let strings: [String] = [
        // .serverPublicKeyEncryptedString_rom0,
        .serverPublicKeyEncryptedString_rom,
        // .serverPublicKeyEncryptedString_rom1,
        // .serverPublicKeyEncryptedString_im,
        // .serverPublicKeyEncryptedString_rom20230810,
            .serverPublicKeyEncryptedString_pyrkova,
    ]
    
    private let encryptedDecryptedStrings: [(encrypted: String, decrypted: String)] = [
        (.serverPublicKeyEncryptedString_rom, .serverPublicKeyDecryptedString_rom),
        (.serverPublicKeyEncryptedString_rom1, .serverPublicKeyDecryptedString_rom1),
        (.serverPublicKeyEncryptedString_rom2, .serverPublicKeyDecryptedString_rom2),
        (.serverPublicKeyEncryptedString_rom3, .serverPublicKeyDecryptedString_rom3),
        (.serverPublicKeyEncryptedString_rom4, .serverPublicKeyDecryptedString_rom4),
    ]
    
    private let rsaAlgorithms: [SecKeyAlgorithm] = [
        // RSA Encryption
        .rsaEncryptionRaw,
        .rsaEncryptionPKCS1,
        // RSA Encryption OAEP
        .rsaEncryptionOAEPSHA1,
        .rsaEncryptionOAEPSHA224,
        .rsaEncryptionOAEPSHA256,
        .rsaEncryptionOAEPSHA384,
        .rsaEncryptionOAEPSHA512,
    ]
    
    private let ellipticCurveKeyExchangeAlgorithms: [SecKeyAlgorithm] = [
        .ecdhKeyExchangeCofactor,
        .ecdhKeyExchangeStandard,
        .ecdhKeyExchangeCofactorX963SHA1,
        .ecdhKeyExchangeStandardX963SHA1,
        .ecdhKeyExchangeCofactorX963SHA224,
        .ecdhKeyExchangeCofactorX963SHA256,
        .ecdhKeyExchangeCofactorX963SHA384,
        .ecdhKeyExchangeCofactorX963SHA512,
        .ecdhKeyExchangeStandardX963SHA224,
        .ecdhKeyExchangeStandardX963SHA256,
        .ecdhKeyExchangeStandardX963SHA384,
        .ecdhKeyExchangeStandardX963SHA512,
    ]
    
    private func transportPublicKey() throws -> SecKey {
        
        try Crypto.transportKey()
    }
    
    private func anyP384PrivateKey() -> P384.KeyAgreement.PrivateKey {
        
        .init()
    }
    
    private func expectIsSupported(
        _ secKey: SecKey,
        _ operation: SecKeyOperationType,
        _ algorithm: SecKeyAlgorithm,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        XCTAssertTrue(
            SecKeyIsAlgorithmSupported(
                secKey,
                operation,
                algorithm
            ),
            "\(algorithm) is not supported.",
            file: file, line: line)
    }
    
    private func createRandom4096RSAKeys() throws -> (
        privateKey: SecKey,
        publicKey: SecKey
    ) {
        try Crypto.createRandomSecKeys(
            keyType: .rsa,
            keySize: .bits4096
        )
    }
}

func anyData(bitCount: Int = 256) -> Data {
    
    let key = SymmetricKey(size: .init(bitCount: bitCount))
    
    return key.withUnsafeBytes { Data($0) }
}

extension Crypto {
    
    /// Encrypt data using RSA key.
    ///
    /// - Parameters:
    ///   - data: Input data to be encrypted.
    ///   - key: RSA key to use for encryption.
    ///   - padding: The type of padding to use. Typically, `PKCS1` is used, which adds PKCS1 padding before encryption.
    /// - Returns: The encrypted data
    static func encrypt(
        _ data: Data,
        with key: SecKey,
        padding: SecPadding = .PKCS1
    ) throws -> Data {
        
        let blockSize = SecKeyGetBlockSize(key)
        
        var encryptedLength = blockSize
        var encryptedData = [UInt8](repeating: 0, count: encryptedLength)
        
        guard let mutableData = NSMutableData(length: blockSize)
        else {
            throw Crypto.Error.encryptionFailed()
        }
        
        let metadata = data
        _ = (metadata as NSData).bytes.bindMemory(to: UInt8.self, capacity: metadata.count)
        let mutableDataBytes = mutableData.mutableBytes.assumingMemoryBound(to: UInt8.self)
        
        let status = SecKeyEncrypt(key, padding, /*data.withUnsafeBytes { $0 }*/ mutableDataBytes, data.count, &encryptedData, &encryptedLength)
        
        guard noErr != status
        else {
            throw Crypto.Error.encryptionFailed("Encryption failed: \(String(describing: SecCopyErrorMessageString(status, nil)))")
        }
        
        return .init(bytes: encryptedData, count: encryptedLength)
    }
    
    static func decrypt(
        _ data: Data,
        with key: SecKey,
        padding: SecPadding = .PKCS1
    ) throws -> Data {
        
        let blockSize = SecKeyGetBlockSize(key)
        
        guard let decryptedMetadata = NSMutableData(length: blockSize)
        else {
            throw Crypto.Error.decryptionFailed()
        }
        
        let metadata = data
        let encryptedMetadata = (metadata as NSData).bytes.bindMemory(to: UInt8.self, capacity: metadata.count)
        let decryptedMetadataBytes = decryptedMetadata.mutableBytes.assumingMemoryBound(to: UInt8.self)
        
        var decryptedMetadataLength = blockSize
        let decryptionStatus = SecKeyDecrypt(key, padding, encryptedMetadata, blockSize, decryptedMetadataBytes, &decryptedMetadataLength)
        
        guard noErr != decryptionStatus
        else {
            throw Crypto.Error.decryptionFailed("Decryption failed: \(String(describing: SecCopyErrorMessageString(decryptionStatus, nil)))")
        }
        
        return .init(bytes: decryptedMetadataBytes, count: decryptedMetadataLength)
    }
}
