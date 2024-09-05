//
//  NanoServices+makeGetServiceCategoryList.swift
//  ForaBank
//
//  Created by Igor Malyarov on 13.08.2024.
//

import AnywayPaymentBackend
import RemoteServices
import GenericRemoteService

extension NanoServices {
    
    typealias GetServiceCategoryListResult = Result<RemoteServices.ResponseMapper.GetServiceCategoryListResponse, ServiceFailure>
    typealias GetServiceCategoryListCompletion = (GetServiceCategoryListResult) -> Void
    typealias GetServiceCategoryList = (@escaping GetServiceCategoryListCompletion) -> Void
    
    static func makeGetServiceCategoryList(
        httpClient: HTTPClient,
        log: @escaping (String, StaticString, UInt) -> Void,
        file: StaticString = #file,
        line: UInt = #line
    ) -> GetServiceCategoryList {
        
        adaptedLoggingFetch(
            createRequest: RequestFactory.createGetServiceCategoryListRequest,
            httpClient: httpClient,
            mapResponse: RemoteServices.ResponseMapper.mapGetServiceCategoryListResponse,
            mapError: ServiceFailure.init,
            log: log,
            file: file,
            line: line
        )
    }
}

