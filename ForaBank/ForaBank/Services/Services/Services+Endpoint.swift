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
        
        enum PathPrefix {
            
            case processing(Processing)
            case dict
            case binding
            case transfer
            
            var path: String {
                
                switch self {
                case let .processing(processing):
                    return "processing/\(processing.rawValue)"

                case .dict:
                    return "dict"

                case .binding:
                    return "rest/binding"

                case .transfer:
                    return "rest/transfer"
                }
            }
            
            enum Processing: String {
                
                case auth
                case authenticate
                case cardInfo
                case registration
            }
        }
        
        enum Version: String {
            
            case v1
            case v2
        }
        
        enum ServiceName: String {
            
            case bindPublicKeyWithEventId
            case changePIN
            case createStickerPayment
            case createSberQRPayment
            case formSessionKey
            case getJsonAbroad
            case getSberQRData
            case getScenarioQRData
            case getStickerPayment
            case getPINConfirmationCode
            case getProcessingSessionCode
            case processPublicKeyAuthenticationRequest
            case showCVV
        }
    }
}

extension Services.Endpoint {
    
    private var path: String {
        
        "/\(pathPrefix.path)/\(version.rawValue)/\(serviceName.rawValue)"
    }
    
    func url(
        withBase base: String,
        parameters: [(String, String)] = []
    ) throws -> URL {
        
        guard let baseURL = URL(string: base)
        else {
            
            throw URLConstructionError()
        }
        
        return try url(withBaseURL: baseURL, parameters: parameters)
    }
    
    func url(
        withBaseURL baseURL: URL,
        parameters: [(String, String)] = []
    ) throws -> URL {
        
        var components = URLComponents()
        components.scheme = baseURL.scheme
        components.host = baseURL.host
        components.port = baseURL.port
        components.path = baseURL.path + path
        
        if !parameters.isEmpty {
            
            components.queryItems = [URLQueryItem]()
            
            components.queryItems = parameters.map { name, value in
                
                let value = value.addingPercentEncoding(
                    withAllowedCharacters: .urlHostAllowed
                )
                
                return .init(name: name, value: value)
            }
        }
        
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
        pathPrefix: .processing(.registration),
        version: .v1,
        serviceName: .bindPublicKeyWithEventId
    )
    
    static let changePIN: Self = .init(
        pathPrefix: .processing(.cardInfo),
        version: .v1,
        serviceName: .changePIN
    )
    
    static let createLandingRequest: Self = .init(
        pathPrefix: .dict,
        version: .v2,
        serviceName: .getJsonAbroad
    )
    
    static let createStickerPayment: Self = .init(
        pathPrefix: .binding,
        version: .v1,
        serviceName: .createStickerPayment
    )
    
    static let createSberQRPayment: Self = .init(
        pathPrefix: .binding,
        version: .v1,
        serviceName: .createSberQRPayment
    )
    
    static let formSessionKey: Self = .init(
        pathPrefix: .processing(.registration),
        version: .v1,
        serviceName: .formSessionKey
    )
    
    static let getPINConfirmationCode: Self = .init(
        pathPrefix: .processing(.cardInfo),
        version: .v1,
        serviceName: .getPINConfirmationCode
    )
    
    static let getProcessingSessionCode: Self = .init(
        pathPrefix: .processing(.registration),
        version: .v1,
        serviceName: .getProcessingSessionCode
    )
    
    static let getSberQRData: Self = .init(
        pathPrefix: .binding,
        version: .v1,
        serviceName: .getSberQRData
    )
    
    static let getScenarioQRData: Self = .init(
        pathPrefix: .binding,
        version: .v1,
        serviceName: .getScenarioQRData
    )
    
    static let getStickerPaymentRequest: Self = .init(
        pathPrefix: .dict,
        version: .v2,
        serviceName: .getStickerPayment
    )
    
    static let processPublicKeyAuthenticationRequest: Self = .init(
        pathPrefix: .processing(.authenticate),
        version: .v1,
        serviceName: .processPublicKeyAuthenticationRequest
    )
    
    static let showCVV: Self = .init(
        pathPrefix: .processing(.cardInfo),
        version: .v1,
        serviceName: .showCVV
    )
}
