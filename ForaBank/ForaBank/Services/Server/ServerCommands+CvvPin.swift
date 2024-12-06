//
//  ServerCommands+CvvPin.swift
//  Vortex
//
//  Created by Igor Malyarov on 21.07.2023.
//

import Foundation
import ServerAgent

extension ServerCommands {
    
    /// A namespace.
    enum CvvPin {}
}

extension ServerCommands.CvvPin {
    
    // https://pl.forabank.ru/dbo/api/v3/processing/registration/v1/getProcessingSessionCode
    
    // https://<DBO_server_url>/dbo/api/v3/processing/registration/{version}/getProcessingSessionCode
    struct GetProcessingSessionCode: ServerCommand {
        
        let token: String
        let endpoint = "/processing/registration/v1/getProcessingSessionCode"
        let method: ServerCommandMethod = .get
        
        struct Payload: Encodable {}
        
        struct Response: ServerResponse {
            
            let statusCode: ServerStatusCode
            let errorMessage: String?
            let data: ServerAPISessionCode?
        }
        
        struct ServerAPISessionCode: Decodable, Equatable {
            
            let code: String
            let phone: String
        }
    }
}
