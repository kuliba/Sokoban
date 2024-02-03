//
//  NanoServices+makeFPSGetConsent.swift
//  ForaBank
//
//  Created by Igor Malyarov on 02.02.2024.
//

import FastPaymentsSettings
import Fetcher
import Foundation
import GenericRemoteService

extension NanoServices {
    
    typealias GetConsentResult = Result<[ConsentMe2MePull], ServiceFailure>
    typealias GetConsentCompletion = (GetConsentResult) -> Void
    typealias GetConsent = (@escaping GetConsentCompletion) -> Void
    
    static func makeFPSGetConsent(
        _ httpClient: HTTPClient,
        _ log: @escaping (String, StaticString, UInt) -> Void
    ) -> GetConsent {
        
        adaptedLoggingRemoteFetch(
            createRequest: ForaBank.RequestFactory.createGetClientConsentMe2MePullRequest,
            httpClient: httpClient,
            mapResponse: FastPaymentsSettings.ResponseMapper.mapGetClientConsentMe2MePullResponse,
            log: log
        )
    }
}
