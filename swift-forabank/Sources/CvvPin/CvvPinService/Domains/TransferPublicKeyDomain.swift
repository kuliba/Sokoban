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
    typealias TransferKey = (OTP, EventID, SharedSecret, @escaping Completion) -> Void
}

extension TransferPublicKeyDomain {
    
    public struct OTP: Equatable {
        
        private let otp: String
        
        public init(value: String) {
         
            self.otp = value
        }
        
        public var value: String { otp }
    }
    
    public struct EventID: Equatable {
        
        private let event: String
        
        public init(value: String) {
         
            self.event = value
        }

        public var value: String { event }
    }
    
    public struct SharedSecret: Equatable {
        
        private let secret: Data
        
        public init(_ secret: Data) {
         
            self.secret = secret
        }

        public var data: Data { secret }
    }
}
