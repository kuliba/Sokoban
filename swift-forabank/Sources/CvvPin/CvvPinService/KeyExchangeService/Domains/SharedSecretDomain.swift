//
//  SharedSecretDomain.swift
//  
//
//  Created by Igor Malyarov on 16.07.2023.
//

import Foundation

/// A namespace.
public enum SharedSecretDomain {}

public extension SharedSecretDomain {
    
    typealias Result = Swift.Result<Data, Error>
    typealias Completion = (Result) -> Void
    typealias ExtractSharedSecret = (String, @escaping Completion) -> Void
}
