//
//  TestTypes.swift
//  
//
//  Created by Igor Malyarov on 04.10.2023.
//

import Foundation
import CVVPINServices

struct CardID: Equatable, RawRepresentable {
    
    let rawValue: Int
}

struct CVV: Equatable {
    
    let value: String
    
    init(_ value: String) {
        
        self.value = value
    }
}

extension CVV: RawRepresentable {
    
    init(rawValue: String) {
        
        self.value = rawValue
    }
    
    var rawValue: String { value }
}

struct EventID: Equatable, RawRepresentable {
    
    let rawValue: String
    
    init(rawValue: String) {
        
        self.rawValue = rawValue
    }
}

typealias ECDHKeyPairDomain = KeyPairDomain<ECDHPublicKey, ECDHPrivateKey>

struct ECDHPublicKey {
    
    let value: String
    
    init(_ value: String) {
        
        self.value = value
    }
}

extension ECDHPublicKey: Base64StringEncodable {
    
    func base64EncodedString() throws -> String {
        
        value.appending("==")
    }
}

struct ECDHPrivateKey: Equatable {
    
    let value: String
    
    init(_ value: String) {
        
        self.value = value
    }
}

struct OTP: Equatable, RawRepresentable {
    
    let rawValue: String
    
    init(rawValue: String) {
        
        self.rawValue = rawValue
    }
}

struct PIN: Equatable, RawRepresentable {
    
    let rawValue: String
    
    init(rawValue: String) {
        
        self.rawValue = rawValue
    }
}

struct RemoteCVV {
    
    let value: String
    
    init(_ value: String) {
        
        self.value = value
    }
}

extension RemoteCVV: RawRepresentable {
    
    init(rawValue: String) {
        
        self.value = rawValue
    }
    
    var rawValue: String { value }
}

typealias RSAKeyPair = (publicKey: RSAPublicKey, privateKey: RSAPrivateKey)

struct RSAPublicKey {
    
    let value: String
    
    init(_ value: String) {
        
        self.value = value
    }
}

extension RSAPublicKey: Base64StringEncodable {
    
    func base64EncodedString() throws -> String {
        
        value.appending("==")
    }
}

struct RSAPrivateKey: Equatable {
    
    let value: String
    
    init(_ value: String) {
        
        self.value = value
    }
}

struct SessionID: Equatable, RawRepresentable {
    
    let rawValue: String
    
    init(rawValue: String) {
        
        self.rawValue = rawValue
    }
}

struct SymmetricKey: Equatable {
    
    let value: String
    
    init(_ value: String) {
        
        self.value = value
    }
}
