//
//  ShowCVVCrypto.swift
//  ForaBank
//
//  Created by Igor Malyarov on 24.10.2023.
//

import ForaCrypto
import Foundation

#warning("refactor as ForaCrypto extension (?)")
enum ShowCVVCrypto {}

extension ShowCVVCrypto {
    
    static func log(_ message: String) {
        
        LoggerAgent.shared.log(level: .debug, category: .crypto, message: message)
    }
    
    static func hashSignVerify(
        string: String,
        publicKey: SecKey,
        privateKey: SecKey
    ) throws -> Data {
        
        let data = Data(string.utf8)
        let signedData = try sign(data, privateKey)
        
        // verify (not used in output)
        let signature = try createSignature(signedData, privateKey)
        try verify(signedData, signature, publicKey)
        
        log("`hashSignVerify` success")
        return signedData
    }
    
    static func sign(
        _ data: Data,
        _ privateKey: SecKey
    ) throws -> Data {
        
        do {
            return try ForaCrypto.Crypto.signNoHash(
                data,
                withPrivateKey: privateKey,
                algorithm: .rsaSignatureRaw
            )
        } catch {
            log("Data signing failure: \(error)")
            throw error
        }
    }
    
    typealias SignedData = Data
    
    static func createSignature(
        _ data: SignedData,
        _ privateKey: SecKey
    ) throws -> Data {
        
        do {
            return try ForaCrypto.Crypto.createSignature(
                for: data,
                usingPrivateKey: privateKey,
                algorithm: .rsaSignatureRaw
            )
        } catch {
            log("Signature creation failure: \(error)")
            throw error
        }
    }
    
    typealias Signature = Data
    
    static func verify(
        _ signedData: SignedData,
        _ signature: Signature,
        _ publicKey: SecKey
    ) throws {
        
        do {
            guard signature.count == 512
            else {
                throw ForaCrypto.Crypto.Error.verificationFailure(
                    NSError(domain: "Signature Size Error: not 512.", code: -1)
                )
            }
            
            do {
                let result = try ForaCrypto.Crypto.verify(
                    signedData,
                    withPublicKey: publicKey,
                    signature: signature,
                    algorithm: .rsaSignatureRaw
                )
                
                if !result {
                    throw ForaCrypto.Crypto.Error.verificationFailure(NSError(domain: "Data was not verified with signature", code: -1))
                }
            } catch {
                log("verify failure: \(error)")
                throw error
            }
        } catch {
            log("verify failure: \(error)")
            throw error
        }
    }
    
    static func decrypt(
        string: String,
        withPrivateKey privateKey: SecKey
    ) throws -> String {
        
        do {
            let decrypted = try ForaCrypto.Crypto.decrypt(
                string,
                with: .rsaEncryptionPKCS1,
                using: privateKey
            )
            log("Data decryption success (\(decrypted.count))")
            
            guard let string = String(data: decrypted, encoding: .utf8)
            else {
                throw NSError(domain: "Data to string conversion failure", code: -1)
            }

            log("Decrypted string (\(string)")
            
            return string
        } catch {
            log("Description error: \(error)")
            throw error
        }
    }
}
