//
//  ResponseMapper+ mapBindPublicKeyWithEventIDResponse.swift
//  Vortex
//
//  Created by Igor Malyarov on 22.10.2023.
//

import CVVPIN_Services
import Foundation

extension ResponseMapper {
    
    static func mapBindPublicKeyWithEventIDResponse(
        _ data: Data,
        _ httpURLResponse: HTTPURLResponse
    ) -> BindPublicKeyWithEventIDService.ProcessResult {
        
        do {
            switch httpURLResponse.statusCode {
            case 200:
                if data.isEmptyJSON {
                    return .success(())
                } else {
                    return .failure(.invalid(statusCode: 200, data: data))
                }
                
            case 500:
                do {
                    let retry = try JSONDecoder().decode(Retry.self, from: data)
                    return .failure(.retry(
                        statusCode: retry.statusCode,
                        errorMessage: retry.errorMessage,
                        retryAttempts: retry.retryAttempts
                    ))
                } catch {
                    let serverError = try JSONDecoder().decode(ServerError.self, from: data)
                    return .failure(.server(
                        statusCode: serverError.statusCode,
                        errorMessage: serverError.errorMessage
                    ))
                }
                
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
    
    private struct Retry: Decodable {
        
        let statusCode: Int
        let errorMessage: String
        let retryAttempts: Int
    }
}
