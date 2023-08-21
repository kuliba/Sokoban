//
//  BindPublicKeyWithEventIDMapper.swift
//  
//
//  Created by Igor Malyarov on 05.08.2023.
//

import Foundation

public enum BindPublicKeyWithEventIDMapper {
    
    public typealias Result = Error?
    
    public static func map(
        _ data: Data,
        _ response: HTTPURLResponse
    ) -> Result {
        
        switch response.statusCode {
        case statusCode200:
            return nil
            
        case statusCode400, statusCode422, statusCode500:
            return handleNon200StatusCode(
                statusCode: response.statusCode,
                with: data
            )
            
        default:
            return handleUnknownStatusCode(
                statusCode: response.statusCode,
                with: data
            )
        }
    }
    
    private static func handleNon200StatusCode(
        statusCode: Int,
        with data: Data
    ) -> Result {
        
        do {
            return try decode(data)
        } catch {
            return .invalidData(statusCode: statusCode)
        }
    }
    
    private static func handleUnknownStatusCode(
        statusCode: Int,
        with data: Data
    ) -> Result {
        
        do {
            return try decode(data)
        } catch {
            return .unknownStatusCode(statusCode)
        }
    }
    
    private static func decode(_ data: Data) throws -> Result {
        
        let decoded = try JSONDecoder().decode(DecodableServerError.self, from: data)
        
        return .apiError(
            .init(
                statusCode: decoded.statusCode,
                errorMessage: decoded.errorMessage,
                retryAttempts: decoded.retryAttempts
            )
        )
    }
    
    private static let statusCode200 = 200
    private static let statusCode400 = 400
    private static let statusCode422 = 422
    private static let statusCode500 = 500
    
    private struct DecodableServerError: Decodable {
        
        let statusCode: Int
        let errorMessage: String
        let retryAttempts: Int?
    }
    
    public enum Error: Swift.Error, Equatable {
        
        case unknownStatusCode(Int)
        case invalidData(statusCode: Int)
        case apiError(APIError)
    }
    
    public struct APIError: Equatable {
        
        public let statusCode: Int
        public let errorMessage: String
        public let retryAttempts: Int?
        
        public init(
            statusCode: Int,
            errorMessage: String,
            retryAttempts: Int?
        ) {
            self.statusCode = statusCode
            self.errorMessage = errorMessage
            self.retryAttempts = retryAttempts
        }
    }
}
