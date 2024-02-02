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
        let version: Version?
        let serviceName: ServiceName
        
        enum PathPrefix {
            
            case processing(Processing)
            case dict
            case binding
            case rest
            case transfer
            
            var path: String {
                
                switch self {
                case let .processing(processing):
                    return "processing/\(processing.rawValue)"

                case .dict:
                    return "dict"

                case .binding:
                    return "rest/binding"

                case .rest:
                    return "rest"

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
            case v4
        }
        
        enum ServiceName: String {
            
            case bindPublicKeyWithEventId
            case changePIN
            case createCommissionProductTransfer
            case createFastPaymentContract
            case createStickerPayment
            case createSberQRPayment
            case fastPaymentContractFindList
            case formSessionKey
            case getBankDefault
            case getCardStatementForPeriod
            case getCardStatementForPeriod_V3
            case getClientConsentMe2MePull
            case getJsonAbroad
            case getSberQRData
            case getOperationDetailByPaymentId
            case getPINConfirmationCode
            case getPrintForm
            case getProcessingSessionCode
            case getProductDynamicParamsList
            case getSvgImageList
            case getScenarioQRData
            case getStickerPayment
            case makeTransfer
            case processPublicKeyAuthenticationRequest
            case showCVV
            case updateFastPaymentContract
        }
    }
}

extension Services.Endpoint {
    
    private var path: String {
        
        let version = version.map { "\($0.rawValue)/"} ?? ""
        return "/\(pathPrefix.path)/\(version)\(serviceName.rawValue)"
    }
    
    func url(
        withBase base: String,
        parameters: [(String, String)] = []
    ) throws -> URL {
        
        guard let baseURL = URL(string: base)
        else { throw URLConstructionError() }
        
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
            
            components.queryItems = parameters.map { name, value in
                
                let value = value.addingPercentEncoding(
                    withAllowedCharacters: .urlHostAllowed
                )
                
                return .init(name: name, value: value)
            }
        }
        
        guard let url = components.url(relativeTo: baseURL)
        else { throw URLConstructionError() }
        
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
    
    static let createCommissionProductTransfer: Self = .init(
        pathPrefix: .transfer,
        version: nil,
        serviceName: .createCommissionProductTransfer
    )
    
    static let createFastPaymentContract: Self = .init(
        pathPrefix: .rest,
        version: .none,
        serviceName: .createFastPaymentContract
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
    
    static let fastPaymentContractFindList: Self = .init(
        pathPrefix: .rest,
        version: .none,
        serviceName: .fastPaymentContractFindList
    )
    
    static let formSessionKey: Self = .init(
        pathPrefix: .processing(.registration),
        version: .v1,
        serviceName: .formSessionKey
    )
    
    static let getBankDefault: Self = .init(
        pathPrefix: .rest,
        version: nil,
        serviceName: .getBankDefault
    )

    static let getCardStatementForPeriod: Self = .init(
        pathPrefix: .rest,
        version: nil,
        serviceName: .getCardStatementForPeriod_V3
    )

    static let getClientConsentMe2MePull: Self = .init(
        pathPrefix: .rest,
        version: .none,
        serviceName: .getClientConsentMe2MePull
    )

    static let getImageList: Self = .init(
        pathPrefix: .dict,
        version: nil,
        serviceName: .getSvgImageList
    )
    
    static let getOperationDetailByPaymentID: Self = .init(
        pathPrefix: .rest,
        version: nil,
        serviceName: .getOperationDetailByPaymentId
    )
    
    static let getPINConfirmationCode: Self = .init(
        pathPrefix: .processing(.cardInfo),
        version: .v1,
        serviceName: .getPINConfirmationCode
    )
    
    static let getPrintForm: Self = .init(
        pathPrefix: .rest,
        version: nil,
        serviceName: .getPrintForm
    )
    
    static let getProcessingSessionCode: Self = .init(
        pathPrefix: .processing(.registration),
        version: .v1,
        serviceName: .getProcessingSessionCode
    )
    
    static let getProductDynamicParamsList: Self = .init(
        pathPrefix: .rest,
        version: .v2,
        serviceName: .getProductDynamicParamsList
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
        serviceName: .getJsonAbroad
    )
    
    static let makeTransfer: Self = .init(
        pathPrefix: .transfer,
        version: nil,
        serviceName: .makeTransfer
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
    
    static let updateFastPaymentContract: Self = .init(
        pathPrefix: .rest,
        version: .none,
        serviceName: .updateFastPaymentContract
    )
}
