//
//  ResponseMapper+GetNotAuthorizedZoneClientInformData.swift
//  ForaBank
//
//  Created by Nikolay Pochekuev on 27.09.2024.
//

import RemoteServices

extension ResponseMapper {
    
    public typealias GetNotAuthorizedZoneClientInformDataResponse = SerialStamped<String, NotAuthorized>
}

extension ResponseMapper {
    
    public struct NotAuthorized: Equatable {
        
        let authBlocking: Bool
        let title: String
        let text: String
        let update: Update
        
        public init(
            authBlocking: Bool,
            title: String,
            text: String,
            update: Update
        ) {
            self.authBlocking = authBlocking
            self.title = title
            self.text = text
            self.update = update
        }
        
        public struct Update: Equatable {
            let action: String
            let platform: String
            let version: String
            let link: String
            
            init(
                action: String,
                platform: String,
                version: String,
                link: String
            ) {
                self.action = action
                self.platform = platform
                self.version = version
                self.link = link
            }
        }
    }

}
