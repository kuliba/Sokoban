//
//  URLRequestFactory+makeRequest.swift
//  
//
//  Created by Igor Malyarov on 12.10.2023.
//

import Foundation

public extension URLRequestFactory {
    
    func makeRequest(
        for service: Service
    ) throws -> URLRequest {
        
        var request = URLRequest(url: url)
        request.httpMethod = service.httpMethod.rawValue
        request.httpBody = try service.httpBody()
        
        return request
    }
}

extension URLRequestFactory.Service {
    
    var httpMethod: HTTPMethod {
        
        switch self {
        case .bindPublicKeyWithEventID, .changePIN, .formSessionKey, .processPublicKeyAuthenticationRequest, .showCVV:
            return .post
            
        case .getPINConfirmationCode, .getProcessingSessionCode:
            return .get
        }
    }
    
    enum HTTPMethod: String {
        
        case get = "GET"
        case post = "POST"
    }
}

extension URLRequestFactory.Service {
    
    func httpBody() throws -> Data? {
        
        switch self {
        case let .bindPublicKeyWithEventID(payload):
            return try payload.json()
            
        case let .changePIN(payload):
            return try payload.json()
            
        case let .formSessionKey(payload):
            return try payload.json()
            
        case let .processPublicKeyAuthenticationRequest(data):
            guard !data.isEmpty
            else {
                throw Error.emptyData
            }
            return data
            
        case let .showCVV(payload):
            return try payload.json()
            
        case let .getPINConfirmationCode(sessionID):
            guard !sessionID.value.isEmpty
            else {
                throw Error.emptySessionID
            }
            return nil
            
        case .getProcessingSessionCode:
            return nil
        }
    }
}
