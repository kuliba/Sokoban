//
//  HTTPDomain.swift
//  
//
//  Created by Igor Malyarov on 09.08.2023.
//

import Foundation

/// A namespace.
public enum HTTPDomain {}

public extension HTTPDomain {
    
    typealias Request = URLRequest
    typealias Response = (Data, HTTPURLResponse)
    typealias Result = Swift.Result<Response, Error>
    typealias Completion = (Result) -> Void
}
