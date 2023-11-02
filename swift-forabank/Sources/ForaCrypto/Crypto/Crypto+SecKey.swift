//
//  Crypto+SecKey.swift
//  
//
//  Created by Igor Malyarov on 18.08.2023.
//

import CryptoKit
import Foundation

public extension Crypto {
    
    // MARK: - x509Representation
    
    /// Returns key X.509 Representation.
    static func x509Representation(
        of key: SecKey
    ) throws -> Data {
        
        try key.x509Representation()
    }
    
    /// Returns data representation of exportable key.
    ///
    /// The operation fails if the key is not exportable, for example if it is bound to a smart card or to the Secure Enclave. It also fails in macOS if the key has the attribute kSecKeyExtractable set to false.
    /// The method returns data in the PKCS #1 format for an RSA key. For an elliptic curve public key, the format follows the ANSI X9.63 standard using a byte string of 04 || X || Y. For an elliptic curve private key, the output is formatted as the public key concatenated with the big endian encoding of the secret scalar, or 04 || X || Y || K. All of these representations use constant size integers, including leading zeros as needed.
    static func externalRepresentation(
        of key: SecKey
    ) throws -> Data {
        
        try key.externalRepresentation()
    }
    
    // MARK: - Sign & Verify
    
    static func sign(
        _ data: Data,
        withPrivateKey privateKey: SecKey,
        algorithm: SecKeyAlgorithm
    ) throws -> Data {
        
        let data = SHA256
            .hash(data: data)
            .withUnsafeBytes { Data($0) }
        
        return try signNoHash(data, withPrivateKey: privateKey, algorithm: algorithm)
    }
    
    static func signNoHash(
        _ data: Data,
        withPrivateKey privateKey: SecKey,
        algorithm: SecKeyAlgorithm
    ) throws -> Data {
        
        var error: Unmanaged<CFError>? = nil
        guard let signed = SecKeyCreateSignature(privateKey, algorithm, data as CFData, &error) as? Data
        else {
            throw Error.signFailure(error?.takeRetainedValue() as? Swift.Error)
        }
        
        return signed
    }
    
    static func verify(
        _ data: Data,
        withPublicKey key: SecKey,
        signature: Data,
        algorithm: SecKeyAlgorithm = .rsaSignatureRaw
    ) throws -> Bool {
        
        var error: Unmanaged<CFError>? = nil
        let isVerified = SecKeyVerifySignature(key, algorithm, data as CFData, signature as CFData, &error)
        if let error {
            throw Error.verificationFailure(error.takeRetainedValue() as Swift.Error)
        }
        
        return isVerified
    }
    
    static func createSignature(
        for data: Data,
        usingPrivateKey key: SecKey,
        algorithm: SecKeyAlgorithm = .rsaSignatureRaw
    ) throws -> Data {
        
        var error: Unmanaged<CFError>? = nil
        guard let signature = SecKeyCreateSignature(key, algorithm, data as CFData, &error) as? Data
        else {
            throw Error.creatingSignatureFailure(error?.takeRetainedValue() as? Swift.Error)
        }
        
        return signature
    }
    
    // MARK: - SecKey
    
    static func decryptPublicKey(
        from string: String,
        with secKey: SecKey,
        decryptionAlgorithm: SecKeyAlgorithm = .rsaEncryptionRaw,
        keyType: KeyType = .ec,
        advancedBy amount: Int = 415
    ) throws -> SecKey {
        
        let decryptedData = try decrypt(string, with: decryptionAlgorithm, using: secKey)
        
        // MARK: - Advance!
        let amount = min(amount, decryptedData.count)
        let advanced = decryptedData.advanced(by: amount)
        
        let publicKey = try createSecKey(
            from: advanced,
            keyType: keyType,
            keyClass: .publicKey
        )
        
        return publicKey
    }
    
    /// Create `SecKey` from given data, with given key type, class, and key size.
    static func createSecKey(
        from data: Data,
        keyType: KeyType = .rsa,
        keyClass: KeyClass,
        keySize: KeySize = .bits4096
    ) throws -> SecKey {
        
        let parameters: [String: Any] = [
            kSecAttrKeyType as String: keyType.value,
            kSecAttrKeyClass as String: keyClass.value,
            kSecAttrKeySizeInBits as String: keySize.rawValue,
            SecKeyKeyExchangeParameter.requestedSize.rawValue as String: 32
        ]
        
        var error: Unmanaged<CFError>? = nil
        guard let publicKey = SecKeyCreateWithData(data as CFData, parameters as CFDictionary, &error)
        else {
            throw Error.secKeyCreationWithDataFailure(bits: keySize.rawValue, keyType: keyType.value, keyClass: keyClass.value, (error!.takeRetainedValue() as Swift.Error).localizedDescription)
        }
        
        return publicKey
    }
    
    enum KeyType {
        
        case ec, ecsecPrimeRandom, rsa
        
        var value: CFString {
            
            switch self {
            case .ec:
                return kSecAttrKeyTypeEC
            case .ecsecPrimeRandom:
                return kSecAttrKeyTypeECSECPrimeRandom
            case .rsa:
                return kSecAttrKeyTypeRSA
            }
        }
    }
    
    enum KeyClass {
        
        case publicKey, privateKey
        
        var value: CFString {
            
            switch self {
            case .publicKey:  return kSecAttrKeyClassPublic
            case .privateKey: return kSecAttrKeyClassPrivate
            }
        }
    }
    
    enum KeySize: Int {
        
        case bits1024 = 1_024
        case bits2048 = 2_048
        case bits4096 = 4_096
    }
    
    /// Create `SecKey` key pair, with given key type, class, and key size.
    static func createRandomSecKeys(
        keyType: KeyType,
        keySize: KeySize
    ) throws -> (
        privateKey: SecKey,
        publicKey: SecKey
    ) {
        let attributes: [String: Any] = [
            kSecAttrKeyType as String: keyType.value,
            kSecAttrKeySizeInBits as String: keySize.rawValue,
            kSecPrivateKeyAttrs as String:
                [kSecAttrIsPermanent as String: false]
        ]
        
        var error: Unmanaged<CFError>?
        guard let privateKey = SecKeyCreateRandomKey(attributes as CFDictionary, &error),
              let publicKey = SecKeyCopyPublicKey(privateKey)
        else {
            throw Error.keysGenerationFailure(
                bits: keySize.rawValue,
                keyType: keyType.value,
                error!.takeRetainedValue()
            )
        }
        
        return (privateKey, publicKey)
    }
    
    /// Use `OpenSSL` to check public and private key files.
    ///
    /// For `RSA` keys:
    ///
    /// ```bash
    ///     openssl rsa -pubin -in public.pem -text -noout
    /// ```
    ///
    /// ```bash
    ///     openssl rsa -in private.pem -check
    ///     openssl rsa -in private.pem -text -noout
    /// ```
    ///
    /// If the key is valid, you should get an output like:
    ///
    /// ```vbnet
    /// RSA key ok
    /// writing RSA key
    /// -----BEGIN RSA PRIVATE KEY-----
    /// ...
    /// -----END RSA PRIVATE KEY-----
    /// ```
    ///
    static func generateKeyPair(
        keyType: KeyType,
        keySize: KeySize,
        isPermanent: Bool = false
    ) throws -> (
        publicKey: SecKey,
        privateKey: SecKey
    ) {
        let parameters: [String: Any] = [
            kSecAttrKeyType as String: keyType.value,
            kSecAttrKeySizeInBits as String: keySize.rawValue,
            kSecPrivateKeyAttrs as String: [
                kSecAttrIsPermanent as String: isPermanent
            ]
        ]
        
        var publicKey, privateKey: SecKey?
        let status = SecKeyGeneratePair(parameters as CFDictionary, &publicKey, &privateKey)
        
        guard status == errSecSuccess,
              let publicKey = publicKey,
              let privateKey = privateKey
        else {
            throw Error.keysPairGenerationFailure(
                keySize: keySize.rawValue,
                keyType: keyType.value,
                status
            )
        }
        
        return (publicKey, privateKey)
    }
    
    static func decrypt(
        _ string: String,
        with decryptionAlgorithm: SecKeyAlgorithm,
        using secKey: SecKey
    ) throws -> Data {
        
        guard let data = Data(base64Encoded: string, options: .ignoreUnknownCharacters)
        else {
            throw Error.dataCreationFromBase64StringFailure(string)
        }
        
        let decryptedData = try decrypt(data, using: decryptionAlgorithm, secKey: secKey)
        
        return decryptedData
    }
    
    static func decrypt(
        _ data: Data,
        using decryptionAlgorithm: SecKeyAlgorithm = .rsaEncryptionPKCS1,
        secKey: SecKey
    ) throws -> Data {
        
        var error: Unmanaged<CFError>? = nil
        guard let decrypted = SecKeyCreateDecryptedData(secKey, decryptionAlgorithm, data as CFData, &error) as Data?
        else {
            throw error!.takeRetainedValue()
        }
        
        return decrypted
    }
    
    /// Extracts key from certificate from the file at given URL.
    static func secKey(fromCertURL url: URL) throws -> SecKey {
        
        let contents = try String(contentsOf: url)
        return try serverCertPublicKey(contents)
    }
    
    // MARK: - From ForaBank
    
    /// Extracts first certificate public RSA key in `SecKey` format from certificates data string
    /// - Parameter certificatesData: certificates data encoded in base64 string
    /// - Returns: first certificate public RSA key
    
    static func serverCertPublicKey(_ certificatesData: String) throws -> SecKey {
        
        // Extract server certificates in PEM from string
        let certificatesPemData = pemCertificates(from: certificatesData)
        
        // Expected first server cert data
        guard let serverCertData = certificatesPemData.first else {
            throw Crypto.Error.notFoundServerCertificateData
        }
        
        // Convert server certificate from PEM into SecCertificate
        let serverCert = try certificate(from: serverCertData)
        
        // Extract key from server certificate
        guard let serverCertKey = SecCertificateCopyKey(serverCert) else {
            throw Crypto.Error.unableExtractPublicKeyFromServerCertificate
        }
        
        return serverCertKey
    }
    
    /// Parses certificates data string into array
    /// - Parameter data: certificates data encoded in base64 string
    /// - Returns: certificates data array in PEM format string
    
    static func pemCertificates(from data: String) -> [String] {
        
        var certs = [String]()
        
        let components = data.components(separatedBy: "\n")
        var currentCert = ""
        for item in components {
            
            if item == "-----BEGIN CERTIFICATE-----" {
                
                currentCert = ""
                currentCert += "-----BEGIN CERTIFICATE-----" + "\n"
                
            } else if item == "-----END CERTIFICATE-----" {
                
                currentCert += "-----END CERTIFICATE-----" + "\n"
                certs.append(currentCert)
                
            } else {
                
                currentCert += item + "\n"
            }
        }
        
        return certs
    }
    
    /// Creates `SecCertificate` from pem certificate string
    /// - Parameter pemData: certificate in PEM format string
    /// - Returns: SecCertificate
    
    static func certificate(from pemData: String) throws -> SecCertificate {
        
        let derString = pemData.replacingOccurrences(of: "-----BEGIN CERTIFICATE-----", with: "")
            .replacingOccurrences(of: "-----END CERTIFICATE-----", with: "")
            .replacingOccurrences(of: "\n", with: "")
            .replacingOccurrences(of: "\r", with: "")
        
        guard let derData = Data(base64Encoded: derString, options: .ignoreUnknownCharacters) as CFData? else {
            throw Crypto.Error.unableDecodeDataFromBase64String
        }
        
        guard let cert = SecCertificateCreateWithData(nil, derData) else {
            throw Crypto.Error.unableExtractCertFromDerData
        }
        
        return cert
    }
}

public extension SecKey {
    
    enum KeyExtractionError: Error {
        case invalidKey
        case conversionFailure
    }
    
    /// Returns key X.509 Representation.
    func x509Representation() throws -> Data {
        
        try externalRepresentation().prependingX509Header()
    }
    
    /// Returns data representation of exportable key.
    ///
    /// The operation fails if the key is not exportable, for example if it is bound to a smart card or to the Secure Enclave. It also fails in macOS if the key has the attribute kSecKeyExtractable set to false.
    /// The method returns data in the PKCS #1 format for an RSA key. For an elliptic curve public key, the format follows the ANSI X9.63 standard using a byte string of 04 || X || Y. For an elliptic curve private key, the output is formatted as the public key concatenated with the big endian encoding of the secret scalar, or 04 || X || Y || K. All of these representations use constant size integers, including leading zeros as needed.
    func externalRepresentation() throws -> Data {
        
        guard let publicKeyData = SecKeyCopyExternalRepresentation(self, nil) as Data?
        else {
            throw KeyExtractionError.invalidKey
        }
        
        return publicKeyData
    }
}

extension Data {
    
    /// https://github.com/henrinormak/Heimdall
    func prependingX509Header() -> Data {
        
        let result = NSMutableData()
        
        let encodingLength: Int = (self.count + 1).encodedOctets().count
        let OID: [CUnsignedChar] = [
            0x30, 0x0d, 0x06, 0x09, 0x2a, 0x86, 0x48, 0x86,
            0xf7, 0x0d, 0x01, 0x01, 0x01, 0x05, 0x00]
        
        var builder: [CUnsignedChar] = []
        
        // ASN.1 SEQUENCE
        builder.append(0x30)
        
        // Overall size, made of OID + bitstring encoding + actual key
        let size = OID.count + 2 + encodingLength + self.count
        let encodedSize = size.encodedOctets()
        builder.append(contentsOf: encodedSize)
        result.append(builder, length: builder.count)
        result.append(OID, length: OID.count)
        builder.removeAll(keepingCapacity: false)
        
        builder.append(0x03)
        builder.append(contentsOf: (self.count + 1).encodedOctets())
        builder.append(0x00)
        result.append(builder, length: builder.count)
        
        // Actual key bytes
        result.append(self)
        
        return result as Data
    }
}

extension NSInteger {
    
    func encodedOctets() -> [CUnsignedChar] {
        // Short form
        if self < 128 {
            return [CUnsignedChar(self)];
        }
        
        // Long form
        let i = Int(log2(Double(self)) / 8 + 1)
        var len = self
        var result: [CUnsignedChar] = [CUnsignedChar(i + 0x80)]
        
        for _ in 0..<i {
            result.insert(CUnsignedChar(len & 0xFF), at: 1)
            len = len >> 8
        }
        
        return result
    }
}
