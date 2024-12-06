//
//  ResponseMapper+mapGetCodeResponse.swift
//  Vortex
//
//  Created by Igor Malyarov on 22.10.2023.
//

import CVVPIN_Services
import Foundation

extension ResponseMapper {
    
    static func mapGetCodeResponse(
        _ data: Data,
        _ httpURLResponse: HTTPURLResponse
    ) -> GetProcessingSessionCodeService.ProcessResult {
        
        do {
            switch httpURLResponse.statusCode {
            case 200:
                let response = try JSONDecoder().decode(Response.self, from: data)
                return .success(.init(
                    code: response.code,
                    phone: response.phone
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
                statusCode: httpURLResponse.statusCode,
                data: data
            ))
        }
    }
    
    private struct Response: Decodable {
        
        let code: String
        let phone: String
    }
}
