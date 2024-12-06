//
//  RSADomain+CustomStringConvertible.swift
//  Vortex
//
//  Created by Igor Malyarov on 01.11.2023.
//

extension RSADomain.PrivateKey: CustomStringConvertible {
    
    var description: String { "RSAPrivateKey" }
}

extension RSADomain.PublicKey: CustomStringConvertible {

    var description: String { "RSAPublicKey" }
}
