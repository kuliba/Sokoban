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
    
    func test_P384PrivateKey_rom() throws {
        
        let strings: [String] = [
            .privateKeyBase64String_rom,
            .privateKeyBase64String_rom4,
        ]
        
        try strings.forEach { string in
            try p384PrivateKeyFactories.forEach { factory in
                
                let base64 = try XCTUnwrap(Data(base64Encoded: string))
                
                for first in 0..<base64.count {
                    
                    try expectKey(with: factory, from: base64, droppingFirst: first)
                }
            }
        }
    }
    
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
        
        let keyTypes: [CFString] = [
            kSecAttrKeyTypeRSA,
            // kSecAttrKeyTypeAES,
            kSecAttrKeyTypeEC,
            kSecAttrKeyTypeECSECPrimeRandom,
        ]
        
        for string in strings {
            for algorithm in rsaAlgorithms {
                for keyType in keyTypes {
                    // MARK: to find options change amount range
                    // for amount in 0..<512 {
                    for amount in 414..<416 {
                        
                        switch (algorithm, keyType, amount) {
                            
                        case (.rsaEncryptionRaw, kSecAttrKeyTypeEC, 415),
                            (.rsaEncryptionRaw, kSecAttrKeyTypeECSECPrimeRandom, 415):
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
    
    // MARK: - Helpers
    
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
        
        try Crypto.secKey(fromCertURL: XCTUnwrap(publicCrtURL))
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
}

extension Crypto {
    
    static func createRandomSecKeys(
        keyType: CFString,
        keySizeInBits: Int
    ) throws -> (
        privateKey: SecKey,
        publicKey: SecKey
    ) {
        let attributes: [String: Any] = [
            kSecAttrKeyType as String: keyType,
            kSecAttrKeySizeInBits as String: keySizeInBits,
            kSecPrivateKeyAttrs as String:
                [kSecAttrIsPermanent as String: false]
        ]
        
        var error: Unmanaged<CFError>?
        guard let privateKey = SecKeyCreateRandomKey(attributes as CFDictionary, &error),
              let publicKey = SecKeyCopyPublicKey(privateKey)
        else {
            throw Error.keysGenerationFailure(
                bits: keySizeInBits,
                keyType: keyType,
                error!.takeRetainedValue()
            )
        }
        
        return (privateKey, publicKey)
    }
}
