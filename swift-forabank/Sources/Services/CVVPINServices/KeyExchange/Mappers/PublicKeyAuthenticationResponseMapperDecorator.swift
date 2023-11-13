//
//  PublicKeyAuthenticationResponseMapperDecorator.swift
//  
//
//  Created by Igor Malyarov on 02.10.2023.
//

import Foundation

public final class PublicKeyAuthenticationResponseMapperDecorator<ECDHPrivateKey, SymmetricKey> {
    
    public typealias Mapper = PublicKeyAuthenticationResponseMapper<ECDHPrivateKey, SymmetricKey>
    public typealias SessionID = PublicKeyAuthenticationResponse.SessionID
    public typealias TTL = TimeInterval
    // store In-Memory SessionKey & EventID with TTL Store
    public typealias Save = (SymmetricKey, SessionID, TTL) -> Void
    
    private let decoratee: Mapper
    private let save: Save
    
    public init(
        decoratee: Mapper,
        save: @escaping Save
    ) {
        self.decoratee = decoratee
        self.save = save
    }
}

extension PublicKeyAuthenticationResponseMapperDecorator {
    
    public func makeSymmetricKey(
        _ response: Mapper.Response,
        with saS: ECDHPrivateKey
    ) throws -> SymmetricKey {
        
        let symmetricKey = try decoratee.makeSymmetricKey(
            from: response,
            with: saS
        )
        save(symmetricKey, response.sessionID, response.sessionTTL)
        
        return symmetricKey
    }
}
