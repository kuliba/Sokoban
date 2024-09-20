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
            case v3
            case v4
            case v5
            case v6
        }
        
        enum ServiceName: String {
            
            case bindPublicKeyWithEventId
            case blockCard
            case changeClientConsentMe2MePull
            case changePIN
            case changeSVCardLimit
            case createAnywayTransfer
            case createCommissionProductTransfer
            case createFastPaymentContract
            case createSberQRPayment
            case createStickerPayment
            case fastPaymentContractFindList
            case formSessionKey
            case getAllLatestPayments
            case getInfoForRepeatPayment
            case getBankDefault
            case getBannerCatalogList
            case getC2BSub
            case getCardStatementForPeriod
            case getCardStatementForPeriod_V3
            case getClientConsentMe2MePull
            case getJsonAbroad
            case getOperationDetailByPaymentId
            case getOperatorsListByParam
            case getPaymentTemplateList
            case getPINConfirmationCode
            case getPrintForm
            case getProductDetails
            case getProductDynamicParamsList
            case getProductListByType
            case getProcessingSessionCode
            case getScenarioQRData
            case getSberQRData
            case getServiceCategoryList
            case getStickerPayment
            case getSVCardLimits
            case getSvgImageList
            case getVerificationCode
            case makeSetBankDefault
            case makeTransfer
            case prepareSetBankDefault
            case processPublicKeyAuthenticationRequest
            case showCVV
            case updateFastPaymentContract
            case unblockCard
            case userVisibilityProductsSettings
        }
    }
}

extension Services.Endpoint {
    
    var path: String {
        
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
    
    static let changeClientConsentMe2MePull: Self = .init(
        pathPrefix: .rest,
        version: .none,
        serviceName: .changeClientConsentMe2MePull
    )
    
    static let changePIN: Self = .init(
        pathPrefix: .processing(.cardInfo),
        version: .v1,
        serviceName: .changePIN
    )
    
    static let changeSVCardLimit: Self = .init(
        pathPrefix: .rest,
        version: .none,
        serviceName: .changeSVCardLimit
    )

    static func createAnywayTransfer(
        version: Services.Endpoint.Version? = nil
    ) -> Self {
        
        return .init(
            pathPrefix: .transfer,
            version: version,
            serviceName: .createAnywayTransfer
        )
    }
    
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
        version: .none,
        serviceName: .getBankDefault
    )
    
    static let getBannerCatalogListV2: Self = .init(
        pathPrefix: .dict,
        version: .v2,
        serviceName: .getBannerCatalogList
    )

    static let getC2BSub: Self = .init(
        pathPrefix: .binding,
        version: .v1,
        serviceName: .getC2BSub
    )
    
    static let getCardStatementForPeriod: Self = .init(
        pathPrefix: .rest,
        version: .v5,
        serviceName: .getCardStatementForPeriod
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
    
    static let getProductDetails: Self = .init(
        pathPrefix: .rest,
        version: .v2,
        serviceName: .getProductDetails
    )
    
    static let getProductDynamicParamsList: Self = .init(
        pathPrefix: .rest,
        version: .v2,
        serviceName: .getProductDynamicParamsList
    )
    
    static let getProductListByType: Self = .init(
        pathPrefix: .rest,
        version: .v5,
        serviceName: .getProductListByType
    )
    
    static let getProductListByTypeV6: Self = .init(
        pathPrefix: .rest,
        version: .v6,
        serviceName: .getProductListByType
    )

    static let getSberQRData: Self = .init(
        pathPrefix: .binding,
        version: .v1,
        serviceName: .getSberQRData
    )
    
    static let getScenarioQRData: Self = .init(
        pathPrefix: .binding,
        version: .v2,
        serviceName: .getScenarioQRData
    )
    
    static let getStickerPaymentRequest: Self = .init(
        pathPrefix: .dict,
        version: .v2,
        serviceName: .getJsonAbroad
    )
    
    static let getServiceCategoryList: Self = .init(
        pathPrefix: .dict,
        version: nil,
        serviceName: .getServiceCategoryList
    )
    
    static let getSVCardLimits: Self = .init(
        pathPrefix: .rest,
        version: .none,
        serviceName: .getSVCardLimits
    )

    static let getPaymentTemplateListV3: Self = .init(
        pathPrefix: .rest,
        version: .v3,
        serviceName: .getPaymentTemplateList
    )
    
    static let getVerificationCode: Self = .init(
        pathPrefix: .transfer,
        version: .v2,
        serviceName: .getVerificationCode
    )
    
    static let makeSetBankDefault: Self = .init(
        pathPrefix: .rest,
        version: .none,
        serviceName: .makeSetBankDefault
    )
    
    static let makeTransfer: Self = .init(
        pathPrefix: .transfer,
        version: nil,
        serviceName: .makeTransfer
    )
    
    static let makeTransferV2: Self = .init(
        pathPrefix: .transfer,
        version: .v2,
        serviceName: .makeTransfer
    )
    
    static let prepareSetBankDefault: Self = .init(
        pathPrefix: .rest,
        version: .none,
        serviceName: .prepareSetBankDefault
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
    
    static let blockCard: Self = .init(
        pathPrefix: .rest,
        version: .none,
        serviceName: .blockCard
    )

    static let unblockCard: Self = .init(
        pathPrefix: .rest,
        version: .none,
        serviceName: .unblockCard
    )

    static let userVisibilityProductsSettings: Self = .init(
        pathPrefix: .rest,
        version: .none,
        serviceName: .userVisibilityProductsSettings
    )

    static let updateFastPaymentContract: Self = .init(
        pathPrefix: .rest,
        version: .none,
        serviceName: .updateFastPaymentContract
    )
    
    static let getOperatorsListByParam: Self = .init(
        pathPrefix: .dict,
        version: .none,
        serviceName: .getOperatorsListByParam
    )
    
    static let getAllLatestPaymentsV2: Self = .init(
        pathPrefix: .rest,
        version: .v2,
        serviceName: .getAllLatestPayments
    )
    
    static let getAllLatestPaymentsV3: Self = .init(
        pathPrefix: .rest,
        version: .v3,
        serviceName: .getAllLatestPayments
    )
    
    static let getInfoForRepeatPayment: Self = .init(
        pathPrefix: .rest,
        version: .v1,
        serviceName: .getInfoForRepeatPayment
    )
}
