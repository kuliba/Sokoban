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
    
    static func makeFPSGetConsent(
        _ httpClient: HTTPClient,
        _ log: @escaping (String, StaticString, UInt) -> Void
    ) -> MicroServices.Facade.GetConsent {
        
        let getClientConsentMe2MePullService = loggingRemoteService(
            createRequest: ForaBank.RequestFactory.createGetClientConsentMe2MePullRequest,
            httpClient: httpClient,
            mapResponse: FastPaymentsSettings.ResponseMapper.mapGetClientConsentMe2MePullResponse,
            log: log
        )
        
        return { completion in
            
            getClientConsentMe2MePullService.fetch { //result in
                
                completion(Consent.init(result: $0))
            }
        }
    }
}

extension Consent {
    
    init?(result: Result<[ConsentMe2MePull], RemoteServiceError<Error, Error, MappingError>>) {
        
        switch result {
        case .failure:
            return nil
            
        case let .success(consents):
            self = .init(consents.map(\.bankID).map { .init(rawValue: $0)} )
        }
    }
}
