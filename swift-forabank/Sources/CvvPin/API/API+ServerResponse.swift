//
//  API+ServerResponse.swift
//  
//
//  Created by Igor Malyarov on 13.07.2023.
//

public extension API {
    
    struct ServerResponse<Payload, ServerStatusCode>: Decodable
    where Payload: Decodable,
          ServerStatusCode: Decodable {
        
        let statusCode: StatusCode
        let errorMessage: String?
        let payload: Payload?
        
        public init(
            statusCode: StatusCode,
            errorMessage: String?,
            payload: Payload?
        ) {
            self.statusCode = statusCode
            self.errorMessage = errorMessage
            self.payload = payload
        }
        
        public enum StatusCode: Decodable {
            
            case ok
            case other(ServerStatusCode)
        }
    }
}

extension API.ServerResponse.StatusCode: Equatable
where ServerStatusCode: Equatable {}

extension API.ServerResponse: Equatable
where Payload: Equatable, ServerStatusCode: Equatable {}
