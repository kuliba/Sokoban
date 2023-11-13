//
//  ResponseMapper+mapFormSessionKeyResponse.swift
//  ForaBank
//
//  Created by Igor Malyarov on 22.10.2023.
//

import CVVPIN_Services
import Foundation

extension ResponseMapper {
    
    static func mapFormSessionKeyResponse(
        _ data: Data,
        _ httpURLResponse: HTTPURLResponse
    ) -> FormSessionKeyService.ProcessResult {
        
        do {
            switch httpURLResponse.statusCode {
            case 200:
                let response = try JSONDecoder().decode(Response.self, from: data)
                return .success(.init(
                    publicServerSessionKey: response.publicServerSessionKey,
                    eventID: response.eventId,
                    sessionTTL: response.sessionTTL
                ))
                
            default:
                let serverError = try JSONDecoder().decode(ServerError.self, from: data)
                return .failure(.server(
                    statusCode: serverError.statusCode,
                    errorMessage: serverError.errorMessage
                ))
            }
        } catch {
            return .failure(.invalid(
                statusCode: httpURLResponse.statusCode, data: data
            ))
        }
    }
    
    private struct Response: Decodable {
        
        let publicServerSessionKey: String
        let eventId: String
        let sessionTTL: Int
    }
}
