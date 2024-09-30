//
//  ServicePaymentProvider.swift
//
//
//  Created by Igor Malyarov on 13.09.2024.
//

import RemoteServices

extension ResponseMapper {
    
    public struct ServicePaymentProvider: Equatable {
        
        public let id: String
        public let inn: String
        public let md5Hash: String?
        public let name: String
        public let type: String
        
        public init(
            id: String,
            inn: String,
            md5Hash: String?,
            name: String,
            type: String
        ) {
            self.id = id
            self.inn = inn
            self.md5Hash = md5Hash
            self.name = name
            self.type = type
        }
    }
}
