//
//  NanoServices+makeFPSChangeConsent.swift
//  ForaBank
//
//  Created by Igor Malyarov on 03.02.2024.
//

import FastPaymentsSettings
import Fetcher

extension NanoServices {
    
    static func makeFPSChangeConsent(
        _ httpClient: HTTPClient,
        _ log: @escaping (String, StaticString, UInt) -> Void
    ) -> ChangeConsent {
        
        adaptedLoggingRemoteFetch(
            createRequest: ForaBank.RequestFactory.createChangeClientConsentMe2MePullRequest,
            httpClient: httpClient,
            mapResponse: FastPaymentsSettings.ResponseMapper.mapChangeClientConsentMe2MePullResponse,
            log: log
        )
    }
}

extension NanoServices {
    
    typealias ChangeConsentPayload = RequestFactory.BankIDList
    typealias ChangeConsentResult = Result<Void, ServiceFailure>
    typealias ChangeConsentCompletion = (ChangeConsentResult) -> Void
    typealias ChangeConsent = (ChangeConsentPayload, @escaping ChangeConsentCompletion) -> Void
}
