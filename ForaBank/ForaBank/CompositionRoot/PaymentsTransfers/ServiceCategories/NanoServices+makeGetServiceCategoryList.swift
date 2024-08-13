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
    
#warning("placeholder `Void` in `GetServiceCategoryListResult` until mapping is ready")
    typealias GetServiceCategoryListResult = Result<Void, ServiceFailure>
    typealias GetServiceCategoryListCompletion = (GetServiceCategoryListResult) -> Void
    typealias GetServiceCategoryList = (@escaping GetServiceCategoryListCompletion) -> Void
    
    static func makeGetServiceCategoryList(
        _ httpClient: HTTPClient,
        _ log: @escaping (String, StaticString, UInt) -> Void,
        file: StaticString = #file,
        line: UInt = #line
    ) -> GetServiceCategoryList {
        
        adaptedLoggingFetch(
            createRequest: RequestFactory.createGetServiceCategoryListRequest,
            httpClient: httpClient,
            mapResponse: { data, _ in
                
                    .success(print(String(data: data, encoding: .utf8)))
            },
            mapError: ServiceFailure.init,
            log: log,
            file: file,
            line: line
        )
    }
}

