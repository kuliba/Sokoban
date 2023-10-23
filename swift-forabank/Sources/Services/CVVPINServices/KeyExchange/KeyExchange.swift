//
//  KeyExchange.swift
//  
//
//  Created by Igor Malyarov on 02.10.2023.
//

import CryptoKit
import Foundation

public protocol Base64StringEncodable {
    
    func base64EncodedString() throws -> String
}

/// ProcessPublicKeyAuthentication
public struct KeyExchange<APIError, ECDHPublicKey, ECDHPrivateKey, RSAPublicKey, RSAPrivateKey, SymmetricKey>
where APIError: Error,
      ECDHPublicKey: Base64StringEncodable,
      RSAPublicKey: Base64StringEncodable {
    
    public typealias ECDHKeyPairDomain = KeyPairDomain<ECDHPublicKey, ECDHPrivateKey>
    public typealias MakeECDHKeyPair = ECDHKeyPairDomain.Get
    public typealias MakeSymmetricKey = (PublicKeyAuthenticationResponse, ECDHPrivateKey) throws -> SymmetricKey
    public typealias Sign = (Data, RSAPrivateKey) throws -> Data
    
    public typealias ProcessResult = Result<PublicKeyAuthenticationResponse, APIError>
    public typealias ProcessCompletion = (ProcessResult) -> Void
    public typealias Process = (Data, @escaping ProcessCompletion) -> Void
    
    
    private let makeECDHKeyPair: MakeECDHKeyPair
    private let makeSymmetricKey: MakeSymmetricKey
    private let sign: Sign
    
    private let process: Process
    
    public init(
        makeECDHKeyPair: @escaping MakeECDHKeyPair,
        sign: @escaping Sign,
        process: @escaping Process,
        makeSymmetricKey: @escaping MakeSymmetricKey
    ) {
        self.makeECDHKeyPair = makeECDHKeyPair
        self.sign = sign
        self.process = process
        self.makeSymmetricKey = makeSymmetricKey
    }
}

public extension KeyExchange {
    
    typealias RSAKeyPair = (publicKey: RSAPublicKey, privateKey: RSAPrivateKey)
    typealias ExchangeKeysResult = Result<SymmetricKey, KeyExchangeError<APIError>>
    typealias Completion = (ExchangeKeysResult) -> Void
    
    func exchangeKeys(
        rsaKeyPair: RSAKeyPair,
        completion: @escaping Completion
    ) {
        do {
            let (paS, saS) = try makeECDHKeyPair()
            let (clientPublicKeyRSA, privateKey) = rsaKeyPair
            
            let json = try KeyExchangeHelper.wrapInJSON(
                clientPublicKeyRSABase64: clientPublicKeyRSA.base64EncodedString(),
                publicApplicationSessionKeyBase64: paS.base64EncodedString(),
                signWithClientSecretKey: { try sign($0, privateKey) }
            )
            
            // processPublicKeyAuthenticationRequest
            process(json) { result in
                
                switch result {
                case let .failure(error):
                    completion(.failure(.apiError(error)))
                    
                case let .success(response):
                    do {
                        let symmetricKey = try makeSymmetricKey(response, saS)
                        completion(.success(symmetricKey))
                    } catch {
                        completion(.failure(.makeSymmetricKeyFailure))
                    }
                }
            }
        } catch {
            completion(.failure(.makeECDHKeyPairOrWrapInJSONFailure))
        }
    }
}

public enum KeyExchangeError<APIError>: Error {
    
    case apiError(APIError)
    case makeECDHKeyPairOrWrapInJSONFailure
    case makeSymmetricKeyFailure
    case missing(Missing)
    
    public enum Missing {
        
        case rsaKeyPair
    }
}

enum KeyExchangeHelper {
    
    static func wrapInJSON(
        clientPublicKeyRSABase64: String,
        publicApplicationSessionKeyBase64: String,
        signWithClientSecretKey: @escaping (Data) throws -> Data
    ) throws -> Data {
        
        // make SHA256 hash of concatenation of base 64 strings of
        // - clientPublicKeyRSA (CLIENT-PUBLIC-KEY) and
        // - publicApplicationSessionKey (PaS)
        let concatenation = clientPublicKeyRSABase64 + publicApplicationSessionKeyBase64
        let data = Data(concatenation.utf8)
        // looks like `SHA256.hash(data:)` is not used
        // let hash = SHA256.hash(data: data)
        
        // sign hash with CLIENT-SECRET-KEY
        let signature = try signWithClientSecretKey(data)
        
        let json = try JSONSerialization.data(withJSONObject: [
            // String(1024): BASE64 encoded CLIENT-PUBLIC-KEY
            "clientPublicKeyRSA": clientPublicKeyRSABase64,
            // String(1024): BASE64 encoded зашифрованный PaS
            "publicApplicationSessionKey": publicApplicationSessionKeyBase64,
            // String(1024): BASE64-строка с цифровой подписью
            "signature": signature.base64EncodedString()
        ] as [String: String])
        
        return json
    }
}
