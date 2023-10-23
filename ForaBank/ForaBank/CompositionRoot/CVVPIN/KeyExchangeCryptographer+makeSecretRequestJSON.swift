//
//  KeyExchangeCryptographer+makeSecretRequestJSON.swift
//  ForaBank
//
//  Created by Igor Malyarov on 22.10.2023.
//

//import CvvPin
import Foundation
import ForaCrypto

extension KeyExchangeCryptographer {
    
    func makeSecretRequestJSON(
        publicKey: P384KeyAgreementDomain.PublicKey
    ) throws -> Data {
        
        // see Services+keyExchangeService.swift:20
        let keyData = try publicKeyData(publicKey)
        let data = try JSONSerialization.data(withJSONObject: [
            "publicApplicationSessionKey": keyData.base64EncodedString()
        ] as [String: Any])
        let encrypted = try transportEncrypt(data)
        
        return encrypted
    }
}
