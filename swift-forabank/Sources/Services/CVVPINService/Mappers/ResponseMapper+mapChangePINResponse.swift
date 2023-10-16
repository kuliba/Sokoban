//
//  ResponseMapper+mapChangePINResponse.swift
//  
//
//  Created by Igor Malyarov on 15.10.2023.
//

import Foundation

public extension ResponseMapper {
    
    typealias ChangePINResult = Result<Void, ChangePINError.APIError>
    
    static func mapChangePINResponse(
        _ data: Data,
        _ httpURLResponse: HTTPURLResponse
    ) -> ChangePINResult {
        
        do {
            switch httpURLResponse.statusCode {
            case 200:
                if data.isEmpty {
                    return .success(())
                } else {
                    return .failure(.invalidData(statusCode: 200, data: data))
                }
                
            case 406:
                let serverError = try JSONDecoder().decode(ServerError.self, from: data)
                return .failure(.weakPIN(
                    statusCode: serverError.statusCode,
                    errorMessage: serverError.errorMessage
                ))
                
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
                    return .failure(.error(
                        statusCode: serverError.statusCode,
                        errorMessage: serverError.errorMessage
                    ))
                }
                
            default:
                let serverError = try JSONDecoder().decode(ServerError.self, from: data)
                return .failure(.error(
                    statusCode: serverError.statusCode,
                    errorMessage: serverError.errorMessage
                ))
            }
        } catch {
            return .failure(.invalidData(
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
