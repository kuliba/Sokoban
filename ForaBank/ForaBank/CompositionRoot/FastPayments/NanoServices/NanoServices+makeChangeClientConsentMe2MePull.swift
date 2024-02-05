//
//  NanoServices+makeChangeClientConsentMe2MePull.swift
//  ForaBank
//
//  Created by Igor Malyarov on 04.02.2024.
//

import FastPaymentsSettings

extension NanoServices {
    
    static func makeChangeClientConsentMe2MePull(
        _ httpClient: HTTPClient,
        _ log: @escaping (String, StaticString, UInt) -> Void
    ) -> Fetch<RequestFactory.BankIDList, Void> {
        
      adaptedLoggingFetch(
            createRequest: ForaRequestFactory.createChangeClientConsentMe2MePullRequest,
            httpClient: httpClient,
            mapResponse: FastResponseMapper.mapChangeClientConsentMe2MePullResponse,
            log: log
        )
    }
}
