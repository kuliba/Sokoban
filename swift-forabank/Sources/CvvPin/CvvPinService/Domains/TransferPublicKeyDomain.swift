//
//  TransferPublicKeyDomain.swift
//  
//
//  Created by Igor Malyarov on 08.08.2023.
//

import Foundation

/// A namespace.
public enum TransferPublicKeyDomain {}

public extension TransferPublicKeyDomain {
    
    typealias Result = Swift.Result<Void, Error>
    typealias Completion = (Result) -> Void
    typealias TransferKey = (OTP, EventID, Data, @escaping Completion) -> Void
}

extension TransferPublicKeyDomain {
    
    public struct OTP: Equatable {
        
        public let value: String
        
        public init(value: String) {
         
            self.value = value
        }
    }
    
    public struct EventID: Equatable {
        
        public let value: String
        
        public init(value: String) {
         
            self.value = value
        }
    }
}
