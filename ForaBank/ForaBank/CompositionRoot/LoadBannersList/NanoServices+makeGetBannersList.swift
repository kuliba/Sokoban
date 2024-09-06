//
//  NanoServices+makeGetBannersList.swift
//  ForaBank
//
//  Created by Andryusina Nataly on 05.09.2024.
//

import AnywayPaymentBackend
import RemoteServices
import GenericRemoteService
import Foundation
import GetBannerCatalogListAPI

extension NanoServices {
    
    typealias GetBannersListResult = Result<GetBannerCatalogListResponse, ServiceFailure>
    typealias GetBannersListCompletion = (GetBannersListResult) -> Void
    typealias GetBannersList = ((String?, TimeInterval), @escaping GetBannersListCompletion) -> Void
    
    static func makeGetBannersList(
        httpClient: HTTPClient,
        log: @escaping (String, StaticString, UInt) -> Void,
        file: StaticString = #file,
        line: UInt = #line
    ) -> GetBannersList{
        
        adaptedLoggingFetch(
            createRequest: RequestFactory.createGetBannerCatalogListV2Request,
            httpClient: httpClient,
            mapResponse: RemoteServices.ResponseMapper.mapGetBannerCatalogListResponse,
            mapError: ServiceFailure.init,
            log: log,
            file: file,
            line: line
        )
    }
}
