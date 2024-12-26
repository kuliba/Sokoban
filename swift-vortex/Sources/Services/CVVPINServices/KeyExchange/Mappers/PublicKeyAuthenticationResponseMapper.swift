//
//  PublicKeyAuthenticationResponseMapper.swift
//  
//
//  Created by Igor Malyarov on 02.10.2023.
//

import Foundation

public final class PublicKeyAuthenticationResponseMapper<ECDHPrivateKey, SymmetricKey> {
    
    public typealias MakeSymmetricKey = (Data, ECDHPrivateKey) throws -> SymmetricKey
    
    private let publicTransportDecrypt: (Data) throws -> Data
    private let makeSymmetricKey: MakeSymmetricKey
    
    public init(
        publicTransportDecrypt: @escaping (Data) throws -> Data,
        makeSymmetricKey: @escaping MakeSymmetricKey
    ) {
        self.publicTransportDecrypt = publicTransportDecrypt
        self.makeSymmetricKey = makeSymmetricKey
    }
}

extension PublicKeyAuthenticationResponseMapper {
    
    public typealias Response = PublicKeyAuthenticationResponse
    
    public func makeSymmetricKey(
        from response: Response,
        with saS: ECDHPrivateKey
    ) throws -> SymmetricKey {
        
        // decrypt publicServerSessionKey using PUBLIC-TRANSPORT-KEY
        let data = try Data(
            base64Encoded: response.publicServerSessionKey.value
        ).get(orThrow: MapperError.invalidBase64String)
        let publicServerSessionKey = try publicTransportDecrypt(data)
        
        // make Symmetric SessionKey
        // K = SaS * publicServerSessionKey
        let symmetricKey = try makeSymmetricKey(publicServerSessionKey, saS)
        
        return symmetricKey
    }
    
    enum MapperError: Error {
        
        case invalidBase64String
    }
}
