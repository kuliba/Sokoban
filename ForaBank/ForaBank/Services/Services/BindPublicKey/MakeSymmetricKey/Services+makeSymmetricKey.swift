//
//  Services+makeSymmetricKey.swift
//  ForaBank
//
//  Created by Igor Malyarov on 04.08.2023.
//

import CvvPin
import Foundation
import GenericRemoteService

extension Services {
    
    typealias SymmetricKeyService = CvvPin.SymmetricKeyService
    
    static func symmetricKeyService(
        httpClient: HTTPClient
    ) -> SymmetricKeyService {
        
        let makePublicKey = {
            
            try ECKeysProvider().generateKeysPair().publicKey
        }
        
        let encrypt: (Data) throws -> Data = { data in
            
            let key = try PublicTransportKeyDomain.fromCert()
            return try Crypto.rsaPKCS1Encrypt(data: data, withPublicKey: key)
        }
        
        let secretRequestCrypto = ECKeysSecretRequestCrypto(
            makePublicKey: makePublicKey,
            encrypt: encrypt
        )
        
        let publicServerSessionKeyAPIClient = RemoteService(
            makeRequest: RequestFactory.makeSecretRequest,
            performRequest: httpClient.performRequest,
            mapResponse: PublicServerSessionKeyMapper.map
        )
        
        let symmetricCrypto = Services.makeSymmetricCrypto(
            httpClient: httpClient
        )
        
        return ComposedSymmetricKeyService(
            secretRequestCrypto: secretRequestCrypto,
            publicServerSessionKeyAPIClient: publicServerSessionKeyAPIClient,
            symmetricCrypto: symmetricCrypto
        )
    }
}

extension RemoteService: CryptoAPIClient {
    
    public func get(
        _ request: Input,
        completion: @escaping Completion
    ) {
        process(request, completion: completion)
    }
}
