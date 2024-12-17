//
//  PublicTransportKeyDomain.swift
//  ForaBank
//
//  Created by Igor Malyarov on 02.08.2023.
//

import Foundation

/// A namespace.
public enum PublicTransportKeyDomain {}

extension PublicTransportKeyDomain {
    
    public static func fromCert() throws -> SecKey {
        
        typealias Agent = CSRFAgent<AESEncryptionAgent>
        
        return try Agent.serverCertPublicKey(certContents())
    }
    
    private static func certContents() throws -> String {

        let url = try Bundle.main.url(forFilename: "public", withExtension: "crt")
        return try String(contentsOf: url)
    }
}
