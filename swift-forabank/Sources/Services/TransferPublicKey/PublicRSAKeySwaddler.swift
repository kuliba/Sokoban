//
//  PublicRSAKeySwaddler.swift
//  
//
//  Created by Igor Malyarov on 06.08.2023.
//

import Foundation

public final class PublicRSAKeySwaddler<OTP, PrivateKey, PublicKey> {
    
    public typealias GenerateRSA4096BitKeys = () throws -> (PrivateKey, PublicKey)
    public typealias SignEncryptOTP = (OTP, PrivateKey) throws -> Data
    public typealias SaveKeys = (PrivateKey, PublicKey) throws -> Void
    public typealias X509Representation = (PublicKey) throws -> Data
    public typealias SharedSecret = SwaddleKeyDomain<OTP>.SharedSecret
    public typealias AESEncrypt128bitChunks = (Data, SharedSecret) throws -> Data
    
    private let generateRSA4096BitKeys: GenerateRSA4096BitKeys
    private let signEncryptOTP: SignEncryptOTP
    private let saveKeys: SaveKeys
    private let x509Representation: X509Representation
    private let aesEncrypt128bitChunks: AESEncrypt128bitChunks
    
    public init(
        generateRSA4096BitKeys: @escaping GenerateRSA4096BitKeys,
        signEncryptOTP: @escaping SignEncryptOTP,
        saveKeys: @escaping SaveKeys,
        x509Representation: @escaping X509Representation,
        aesEncrypt128bitChunks: @escaping AESEncrypt128bitChunks
    ) {
        self.generateRSA4096BitKeys = generateRSA4096BitKeys
        self.signEncryptOTP = signEncryptOTP
        self.saveKeys = saveKeys
        self.x509Representation = x509Representation
        self.aesEncrypt128bitChunks = aesEncrypt128bitChunks
    }
    
    public func swaddleKey(
        with otp: OTP,
        and sharedSecret: SharedSecret
    ) throws -> Data {
        
        let (encryptedSignedOTP, privateKey, publicKey) = try retrySignEncryptOTP(otp)
        
        try saveKeys(privateKey, publicKey)
        
        let publicKeyX509Representation = try x509Representation(publicKey)
        
        let procClientSecretOTP = encryptedSignedOTP.base64EncodedString()
        let clientPublicKeyRSA = publicKeyX509Representation.base64EncodedString()
        
        let json = try JSONSerialization.data(withJSONObject: [
            "procClientSecretOTP": procClientSecretOTP,
            "clientPublicKeyRSA": clientPublicKeyRSA
        ] as [String: String])
        
#if DEBUG
        print(">>> encryptedSignedOTP count: \(encryptedSignedOTP)\n>>> procClientSecretOTP.count: \(procClientSecretOTP.count)\n", "\(#file):\(#line)")
        dump(procClientSecretOTP)
        
        print(">>> publicKeyData count: \(publicKeyX509Representation.count)\n>>> clientPublicKeyRSA.count: \(clientPublicKeyRSA.count)\n", "\(#file):\(#line)")
        dump(clientPublicKeyRSA)
        print(">>> json:\n", String(data: json, encoding: .utf8)!)
        
        if type(of: publicKey) is SecKey {
            
            do {
                let publicKeyData = try (publicKey as! SecKey).publicKeyRepresentation()
                let (modulus, exponent) = try publicKeyData.extractRSAModulusAndExponent()
                print(">>> Public Key modulus")
                dump(modulus.hexEncodedString())
                dump(modulus.base64EncodedString())
                print(">>> Public Key exponent")
                dump(exponent.hexEncodedString())
                dump(exponent.base64EncodedString())
            } catch {
                print(">>> ", errorMessage.localizedDescription, "\(#file):\(#line)")
            }
        }
#endif
        
        let data: Data = try aesEncrypt128bitChunks(json, sharedSecret)
        
        return data
    }
    
    private func retrySignEncryptOTP(
        _ otp: OTP
    ) throws -> (Data, PrivateKey, PublicKey) {
        
        try retry {
            
            let (privateKey, publicKey) = try generateRSA4096BitKeys()
            let encryptedSignedOTP = try signEncryptOTP(otp, privateKey)
            
            return (encryptedSignedOTP, privateKey, publicKey)
        }
    }
    
#warning("this might already be a part of make...Request")
    func makeSecretJSON(
        eventID: EventID,
        data: Data
    ) throws -> Data {
        
        let json = try JSONSerialization.data(withJSONObject: [
            "eventId": eventID.value,
            "data": data.base64EncodedString()
        ] as [String: Any])
        
        return json
    }
}

struct EventID {
    
    let value: String
}

extension SecKey {

    func publicKeyRepresentation() throws -> Data {
        
        guard let keyData = SecKeyCopyExternalRepresentation(self, nil) as Data?
        else {
            throw NSError(domain: "External Representation error", code: -1)
        }
        
        return keyData
    }
}

enum PublicKeyExtractionError: Error {
    case invalidFormat
    case unexpectedTag(tag: UInt8, index: Int)
    case lengthOutOfBounds
}

extension Data {
    
    func extractRSAModulusAndExponent() throws -> (modulus: Data, exponent: Data) {
        
        var index = 0
        
        // Navigate past outer sequence
        try skipASN1Sequence(at: &index)
        
        // Extract modulus
        let modulus = try decodeASN1Integer(at: &index)
        
        // Extract exponent
        let exponent = try decodeASN1Integer(at: &index)
        
        return (modulus, exponent)
    }

    func extractASN1Length(at index: inout Int) throws -> Int {
        
        guard index < self.count
        else { throw PublicKeyExtractionError.invalidFormat }

        var length = Int(self[index])
        index += 1
        
        if length & 0x80 != 0 { // Multi-byte length
            let lengthBytesCount = length & 0x7f
            guard lengthBytesCount <= 2
            else { throw PublicKeyExtractionError.lengthOutOfBounds }
            
            length = 0
            for _ in 0..<lengthBytesCount {
                length = (length << 8) + Int(self[index])
                index += 1
            }
        }
        return length
    }
    
    func skipASN1Sequence(at index: inout Int) throws {
        
        guard self[index] == 0x30
        else {
            let surroundingData = subdata(in: Swift.max(0, index-10)..<Swift.min(count, index+10))
            print("Surrounding data:", surroundingData as NSData)

            throw PublicKeyExtractionError.unexpectedTag(tag: self[index], index: index)
        }
        
        index += 1
        _ = try extractASN1Length(at: &index)
    }

    func decodeASN1Integer(at index: inout Int) throws -> Data {
        
        guard self[index] == 0x02
        else {
            throw PublicKeyExtractionError.unexpectedTag(tag: self[index], index: index)
        }
        index += 1
        let length = try extractASN1Length(at: &index)
        let dataRange = index..<index + length
        
        guard dataRange.upperBound <= self.count
        else { throw PublicKeyExtractionError.invalidFormat }
        
        index += length
        return self.subdata(in: dataRange)
    }
}

extension Data {
    func hexEncodedString() -> String {
        
        return self.map { String(format: "%02x", $0) }.joined()
    }
}
