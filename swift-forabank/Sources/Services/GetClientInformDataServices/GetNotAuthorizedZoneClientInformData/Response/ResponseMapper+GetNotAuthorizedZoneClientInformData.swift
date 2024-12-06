//
//  ResponseMapper+GetNotAuthorizedZoneClientInformData.swift
//  Vortex
//
//  Created by Nikolay Pochekuev on 27.09.2024.
//

import RemoteServices

extension ResponseMapper {
    
    public typealias GetNotAuthorizedZoneClientInformDataResponse = SerialStamped<String, GetNotAuthorizedZoneClientInformData>
}

extension ResponseMapper {
    
    public struct GetNotAuthorizedZoneClientInformData: Equatable {
        
        public let authBlocking: Bool
        public let title: String
        public let text: String
        public let update: Update?
        
        public init(
            authBlocking: Bool,
            title: String,
            text: String,
            update: Update?
        ) {
            self.authBlocking = authBlocking
            self.title = title
            self.text = text
            self.update = update
        }
        
        public struct Update: Equatable {
            
            public let type: String
            public let platform: String
            public let version: String
            public let link: String
            
            public init(
                type: String,
                platform: String,
                version: String,
                link: String
            ) {
                self.type = type
                self.platform = platform
                self.version = version
                self.link = link
            }
        }
    }
}
