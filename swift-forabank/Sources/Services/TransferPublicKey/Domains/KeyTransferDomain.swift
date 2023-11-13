//
//  KeyTransferDomain.swift
//  
//
//  Created by Igor Malyarov on 24.08.2023.
//

import Foundation

/// A namespace.
public enum KeyTransferDomain {}

public extension KeyTransferDomain {
    
    typealias Result = Swift.Result<Void, ErrorWithRetry>
    typealias Completion = (Result) -> Void
}
