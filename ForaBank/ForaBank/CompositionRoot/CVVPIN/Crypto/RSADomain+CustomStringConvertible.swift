//
//  RSADomain+CustomStringConvertible.swift
//  ForaBank
//
//  Created by Igor Malyarov on 01.11.2023.
//

extension RSADomain.PrivateKey: CustomStringConvertible {
    
    var description: String { "RSAPrivateKey" }
}

extension RSADomain.PublicKey: CustomStringConvertible {

    var description: String { "RSAPublicKey" }
}
#warning("move to Logging")
extension LoggingLoaderDecorator: CustomStringConvertible {
    
    var description: String { "LoaderDecorator<\(T.self)>" }
}
