//
//  Services+getBannerCatalogListV2.swift
//  ForaBank
//
//  Created by Andryusina Nataly on 02.09.2024.
//

import Foundation
import GenericRemoteService
import GetBannerCatalogListAPI

extension Services {
    
    typealias GetBannerCatalogListV1Response = ServerCommands.DictionaryController.GetBannerCatalogList.Response.BannerCatalogData

    typealias GetBannerCatalogListCompletion = (GetBannerCatalogListV1Response?) -> Void
    typealias GetBannerCatalogList = (String?, @escaping GetBannerCatalogListCompletion) -> Void
    
    static func getBannerCatalogListV2(
        _ httpClient: HTTPClient,
        _ timeout: TimeInterval = 120.0,
        logger: LoggerAgentProtocol
    ) -> GetBannerCatalogList {
        
        let infoNetworkLog = { logger.log(level: .info, category: .network, message: $0, file: $1, line: $2) }
        
        let loggingRemoteService = LoggingRemoteServiceDecorator(
            createRequest: RequestFactory.createGetBannerCatalogListV2Request,
            performRequest: httpClient.performRequest,
            mapResponse: GetBannerCatalogListAPI.ResponseMapper.mapGetBannerCatalogListResponse,
            log: infoNetworkLog
        ).remoteService
        
        return { serial, completion in
            
            loggingRemoteService.process((serial, timeout)) { result in
                
                completion(try? Services .mapGetBannerCatalogListResponse(result.get()))
                _ = loggingRemoteService
            }
        }
    }
    
    static func mapGetBannerCatalogListResponse(
        _ response: GetBannerCatalogListResponse
    ) -> GetBannerCatalogListV1Response {
        
        .init(
            bannerCatalogList: response.bannerCatalogList.map {
                .init($0)
        },
            serial: response.serial ?? "")
    }    
}

private extension BannerCatalogListData {
    
    init(_ data: GetBannerCatalogListResponse.Item) {
        
        self.init(
            productName: data.productName,
            conditions: data.conditions,
            imageEndpoint: data.links.image,
            orderURL: URL(string: data.links.order),
            conditionURL: URL(string: data.links.condition),
            action: data.action?.bannerAction
        )
    }
}

private extension GetBannerCatalogListResponse.BannerAction {
    
    var bannerAction: BannerAction? {
        
        switch self.type {
            
        case let .openDeposit(depositId):
            return BannerActionDepositOpen(depositProductId: depositId)
        case .depositsList:
            return BannerActionDepositsList.init(type: .depositsList)
        case let .migTransfer(countryId):
            return BannerActionMigTransfer(countryId: countryId)
        case let .migAuthTransfer(countryId):
            return BannerActionMigAuthTransfer(countryId: countryId)
        case let .contact(countryId):
            return BannerActionContactTransfer(countryId: countryId)
        case let .depositTransfer(countryId):
            return BannerActionDepositTransfer(countryId: countryId)
        case let .landing(target):
            return BannerActionLanding(target: target)
        }
    }
}
