//
//  GetProcessingSessionCodeMapper.swift
//  
//
//  Created by Igor Malyarov on 31.07.2023.
//

import Foundation

public enum GetProcessingSessionCodeMapper {
    
    public typealias Result = SessionCodeDomain.Result
    
    public static func mapResponse(
        _ data: Data,
        _ httpURLResponse: HTTPURLResponse
    ) -> Result {
        
        let statusCode = httpURLResponse.statusCode
        
        switch statusCode {
        case statusCode200:
            return handle200(with: data)
            
        case statusCode500:
            return handle500(with: data)
            
        default:
            return .failure(.unknownStatusCode(statusCode))
        }
    }
    
    private static func handle200(with data: Data) -> Result {
        
        do {
            let decodableGetProcessingSessionCode = try JSONDecoder().decode(DecodableGetProcessingSessionCode.self, from: data)
            
            return .success(decodableGetProcessingSessionCode.sessionCode)
        } catch {
            return .failure(.invalidData(statusCode: 200))
        }
    }
    
    private static func handle500(with data: Data) -> Result {
        
        do {
            let decoded = try JSONDecoder().decode(ServerError.self, from: data)
            return .failure(.serverError(statusCode: decoded.statusCode, errorMessage: decoded.errorMessage))
        } catch {
            return .failure(.invalidData(statusCode: statusCode500))
        }
    }
    
    private struct DecodableGetProcessingSessionCode: Decodable {
        
        let code: String
        let phone: String
        
        var sessionCode: SessionCodeDomain.GetProcessingSessionCode {
            
            .init(code: code, phone: phone)
        }
    }
    
    private struct ServerError: Decodable {
        
        let statusCode: Int
        let errorMessage: String
    }
}

private let statusCode200 = 200
private let statusCode500 = 500
