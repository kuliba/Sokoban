//
//  NanoServices+prepareSetBankDefault.swift
//  ForaBank
//
//  Created by Igor Malyarov on 04.02.2024.
//

import FastPaymentsSettings

extension NanoServices {
    
    static func prepareSetBankDefault(
        _ httpClient: HTTPClient,
        _ log: @escaping (String, StaticString, UInt) -> Void
    ) -> VoidFetch<Void, ServiceFailure> {
#warning("move to the call site")
     return adaptedLoggingFetch(
            createRequest: ForaRequestFactory.createPrepareSetBankDefaultRequest,
            httpClient: httpClient,
            mapResponse: FastResponseMapper.mapPrepareSetBankDefaultResponse,
            mapError: ServiceFailure.init(error:),
            log: log
        )
    }
}
