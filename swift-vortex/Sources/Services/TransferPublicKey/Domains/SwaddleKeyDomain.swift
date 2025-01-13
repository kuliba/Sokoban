//
//  SwaddleKeyDomain.swift
//  
//
//  Created by Igor Malyarov on 24.08.2023.
//

import Foundation

public enum SwaddleKeyDomain<OTP> {}

public extension SwaddleKeyDomain {
    
    typealias Result = Swift.Result<Data, Error>
    typealias Completion = (Result) -> Void
    typealias SwaddleKey = (OTP, SharedSecret, @escaping Completion) -> Void
}

extension SwaddleKeyDomain {
    
    public struct SharedSecret {
        
        private let secret: Data
        
        public init(_ data: Data) {
            
            self.secret = data
        }
        
        public var data: Data { secret }
    }
}
