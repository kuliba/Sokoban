//
//  ResponseMapper+mapChangePINResponse.swift
//  
//
//  Created by Igor Malyarov on 15.10.2023.
//

import Foundation

public extension ResponseMapper {
    
    typealias ChangePINResult = Result<Void, ChangePINMappingError>
    
    static func mapChangePINResponse(
        _ data: Data,
        _ httpURLResponse: HTTPURLResponse
    ) -> ChangePINResult {
        
        do {
            switch httpURLResponse.statusCode {
            case 200:
                if data.isEmptyJSON {
                    return .success(())
                } else {
                    return .failure(.invalidData(statusCode: 200, data: data))
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
                    if serverError.statusCode == weakPINServerStatusCode() {
                        
                        return .failure(.weakPIN(
                            statusCode: serverError.statusCode,
                            errorMessage: serverError.errorMessage
                        ))
                        
                    } else {
                        return .failure(.error(
                            statusCode: serverError.statusCode,
                            errorMessage: serverError.errorMessage
                        ))
                    }
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
    
    enum ChangePINMappingError: Error {
        
        case error(
            statusCode: Int,
            errorMessage: String
        )
        case invalidData(statusCode: Int, data: Data)
        case retry(
            statusCode: Int,
            errorMessage: String,
            retryAttempts: Int
        )
        case weakPIN(
            statusCode: Int,
            errorMessage: String
        )
    }
    
    private struct Retry: Decodable {
        
        let statusCode: Int
        let errorMessage: String
        let retryAttempts: Int
    }
    
    private static func weakPINServerStatusCode() -> Int { 7051 }
}
