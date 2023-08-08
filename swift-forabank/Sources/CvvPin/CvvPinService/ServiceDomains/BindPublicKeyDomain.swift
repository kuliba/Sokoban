//
//  BindPublicKeyDomain.swift
//  
//
//  Created by Igor Malyarov on 08.08.2023.
//

/// A namespace.
public enum BindPublicKeyDomain {}

public extension BindPublicKeyDomain {
    
    typealias Result = Swift.Result<(SessionID, APISymmetricKey), Error>
    typealias Completion = (Result) -> Void
    typealias BindPublicKey = (APISymmetricKey, @escaping Completion) -> Void
}
