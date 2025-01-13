//
//  composeShowCVV.swift
//  
//
//  Created by Igor Malyarov on 10.10.2023.
//

import Foundation

// MARK: - Show CVV

extension CVVPINComposer
where CardID: RawRepresentable<Int>,
      CVV: RawRepresentable<String>,
      RemoteCVV: RawRepresentable<String>,
      SessionID: RawRepresentable<String> {
    
    public typealias CVVService = ShowCVVService<ShowCVVAPIError, CardID, RemoteCVV, CVV, RSAPublicKey, RSAPrivateKey, SessionID, SymmetricKey>
    
    func composeShowCVV() -> CVVService {
        
        typealias JSONMaker = ShowCVVJSONMaker<CardID, RSAPublicKey, RSAPrivateKey, SessionID, SymmetricKey>
        
        let jsonMaker = JSONMaker(
            hashSignVerify: crypto.hashSignVerify,
            aesEncrypt: crypto.aesEncrypt
        )
        
        return .init(
            infra: .init(
                loadRSAKeyPair: infra.loadRSAKeyPair,
                loadSessionID: infra.loadSessionID,
                loadSymmetricKey: infra.loadSymmetricKey,
                process: remote.showCVVProcess
            ),
            makeJSON: jsonMaker.makeSecretJSON,
            transcodeCVV: transcodeCVV
        )
    }
    
    private func transcodeCVV(
        remoteCVV: RemoteCVV,
        with privateKey: RSAPrivateKey
    ) throws -> CVV {
        
        guard let data = Data(base64Encoded: remoteCVV.rawValue)
        else {
            throw TranscodeError.base64ConversionFailure
        }
        let decrypted = try crypto.rsaDecrypt(data, privateKey)
        guard let cvvRawValue = String(data: decrypted, encoding: .utf8),
              let cvv = CVV(rawValue: cvvRawValue)
        else {
            throw TranscodeError.dataToStringConversionFailure
        }
        
        return cvv
    }
    
    enum TranscodeError: Error {
        
        case base64ConversionFailure
        case dataToStringConversionFailure
    }
}

// MARK: - Adapter

public extension CVVPINCrypto {
    
    func hashSignVerify(
        string: String,
        publicKey: RSAPublicKey,
        privateKey: RSAPrivateKey
    ) throws -> Data {
        
        let data = Data(string.utf8)
        let signedData = try sign(data, privateKey)
        
        // verify
        let signature = try createSignature(signedData, privateKey)
        _ = try verify(signedData, signature, publicKey)
        
#warning("move this to the injected `verify`")
        //        guard signature.count == 512
        //        else {
        //            throw NSError(domain: "Signature Error", code: -1)
        //        }
        
        return signedData
    }
}
