//
//  ResponseMapper+mapProcessPublicKeyAuthenticationResponse.swift
//  
//
//  Created by Igor Malyarov on 15.10.2023.
//

import Foundation

public struct ProcessPublicKeyAuthenticationResponse: Equatable {
    
    public let sessionID: String
    public let publicServerSessionKey: String
    public let sessionTTL: Int
    
    public init(
        sessionID: String,
        publicServerSessionKey: String,
        sessionTTL: Int
    ) {
        self.sessionID = sessionID
        self.publicServerSessionKey = publicServerSessionKey
        self.sessionTTL = sessionTTL
    }
}

public extension ResponseMapper {
    
    typealias ProcessPublicKeyAuthenticationResult = Result<ProcessPublicKeyAuthenticationResponse, KeyExchangeError.APIError>
    
    static func mapProcessPublicKeyAuthenticationResponse(
        _ data: Data,
        _ httpURLResponse: HTTPURLResponse
    ) -> ProcessPublicKeyAuthenticationResult {
        
        do {
            switch httpURLResponse.statusCode {
            case 200:
                let auth = try JSONDecoder().decode(Auth.self, from: data)
                return .success(.init(
                    sessionID: auth.sessionId,
                    publicServerSessionKey: auth.publicServerSessionKey,
                    sessionTTL: auth.sessionTTL
                ))
                
            default:
                let serverError = try JSONDecoder().decode(ServerError.self, from: data)
                return .failure(.error(
                    statusCode: serverError.statusCode,
                    errorMessage: serverError.errorMessage
                ))
            }
        } catch {
            return .failure(.invalidData(
                statusCode: httpURLResponse.statusCode,
                data: data
            ))
        }
    }
    
    private struct Auth: Decodable {
        
        let sessionId: String
        let publicServerSessionKey: String
        let sessionTTL: Int
    }
}
