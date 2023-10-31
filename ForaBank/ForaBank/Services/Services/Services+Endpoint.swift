//
//  Services+Endpoint.swift
//  ForaBank
//
//  Created by Igor Malyarov on 31.07.2023.
//

import Foundation

extension Services {
    
    struct Endpoint {
        
        let pathPrefix: PathPrefix
        let version: Version
        let serviceName: ServiceName
        
        enum PathPrefix: String {
            
            case processingRegistration = "processing/registration"
            case dict = "dict"
            case binding = "rest/binding"
            case transfer = "rest/transfer"
        }
        
        enum Version: String {
            
            case v1
            case v2
        }
        
        enum ServiceName: String {
            
            case bindPublicKeyWithEventId
            case formSessionKey
            case getJsonAbroad
            case getProcessingSessionCode
            case getScenarioQRData
            case getStickerPayment
        }
    }
}

extension Services.Endpoint {
    
    private var path: String {
        
        "/\(pathPrefix.rawValue)/\(version.rawValue)/\(serviceName.rawValue)"
    }
    
    func url(withBase base: String) throws -> URL {
        
        guard let baseURL = URL(string: base)
        else {
            
            throw URLConstructionError()
        }
        
        return try url(withBaseURL: baseURL)
    }
    
    func url(withBaseURL baseURL: URL) throws -> URL {
        
        var components = URLComponents()
        components.scheme = baseURL.scheme
        components.host = baseURL.host
        components.port = baseURL.port
        components.path = baseURL.path + path
        
        guard let url = components.url(relativeTo: baseURL)
        else {
            throw URLConstructionError()
        }
        
        return url
    }
    
    struct URLConstructionError: Error {}
}

extension Services.Endpoint {
    
    static let bindPublicKeyWithEventID: Self = .init(
        pathPrefix: .processingRegistration,
        version: .v1,
        serviceName: .bindPublicKeyWithEventId
    )
    
    static let formSessionKey: Self = .init(
        pathPrefix: .processingRegistration,
        version: .v1,
        serviceName: .formSessionKey
    )
    
    static let getProcessingSessionCode: Self = .init(
        pathPrefix: .processingRegistration,
        version: .v1,
        serviceName: .getProcessingSessionCode
    )
    
    static let createLandingRequest: Self = .init(
        pathPrefix: .dict,
        version: .v2,
        serviceName: .getJsonAbroad
    )
    
    static let getScenarioQRDataRequest: Self = .init(
        pathPrefix: .binding,
        version: .v1,
        serviceName: .getScenarioQRData
    )
    
    static let getStickerPaymentRequest: Self = .init(
        pathPrefix: .binding,
        version: .v2,
        serviceName: .getStickerPayment
    )
}

extension Services.Endpoint {
    
    func url(withBase base: String, parameters: [(String, String)]) throws -> URL {
        
        guard let baseURL = URL(string: base)
        else {
            
            throw URLConstructionError()
        }
        
        return try url(withBaseURL: baseURL, parameters: parameters)
    }
    
    
    func url(withBaseURL baseURL: URL, parameters: [(String, String)]) throws -> URL {
        
        var components = URLComponents()
        components.scheme = baseURL.scheme
        components.host = baseURL.host
        components.port = baseURL.port
        components.path = baseURL.path + path
        
        if !parameters.isEmpty {
            
            components.queryItems = [URLQueryItem]()
            
            components.queryItems = parameters.map { (key, value) in
                URLQueryItem(
                    name: key,
                    value: "\(value)".addingPercentEncoding(withAllowedCharacters: .urlHostAllowed))
            }
        }
        
        guard let url = components.url(relativeTo: baseURL)
        else {
            throw URLConstructionError()
        }
        
        return url
    }
}
