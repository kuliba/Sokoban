//
//  NanoServices+makeGetC2BSub.swift
//  ForaBank
//
//  Created by Igor Malyarov on 04.02.2024.
//

import FastPaymentsSettings

extension NanoServices {
    
    static func makeGetC2BSub(
        _ httpClient: HTTPClient,
        _ log: @escaping (String, StaticString, UInt) -> Void
    ) -> VoidFetch<GetC2BSubscription> {
        
        adaptedLoggingFetch(
            createRequest: ForaRequestFactory.createGetC2BSubRequest,
            httpClient: httpClient,
            mapResponse: FastResponseMapper.mapGetC2BSubResponseResponse,
            log: log
        )
    }
}
