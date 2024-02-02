//
//  NanoServices+makeFPSGetBankDefault.swift
//  ForaBank
//
//  Created by Igor Malyarov on 02.02.2024.
//

import FastPaymentsSettings
import Fetcher
import Foundation
import GenericRemoteService

extension NanoServices {
    
    // getBankDefault
    typealias GetBankDefaultResult = Result<BankDefault, ServiceFailure>
    typealias GetBankDefaultCompletion = (GetBankDefaultResult) -> Void
    typealias GetBankDefault = (PhoneNumber, @escaping GetBankDefaultCompletion) -> Void
    
    static func makeFPSGetBankDefault(
        httpClient: HTTPClient,
        log: @escaping (String, StaticString, UInt) -> Void
    ) -> GetBankDefault {
        
        let getBankDefaultService = loggingRemoteService(
            createRequest: ForaBank.RequestFactory.createGetBankDefaultRequest,
            httpClient: httpClient,
            mapResponse: FastPaymentsSettings.ResponseMapper.mapGetBankDefaultResponse,
            log: log
        )
        #warning("use adapter to simplify expression")
        return { payload, completion in
            
            getBankDefaultService.fetch(.init(payload.rawValue)) {
                
                completion($0
                    .map { .init($0.rawValue) }
                    .mapError(ServiceFailure.init(error:))
                )
            }
        }
    }
}

// MARK: - Adapters

private extension ServiceFailure {
    
    init(error: RemoteServiceError<Error, Error, GetBankDefaultMappingError>) {
        
        switch error {
        case .createRequest, .performRequest:
            self = .connectivityError
            
        case let .mapResponse(mapResponseError):
            switch mapResponseError {
            case .invalid:
                self = .connectivityError
                
            case let .limit(errorMessage),
                let .server(_, errorMessage):
                self = .serverError(errorMessage)
            }
        }
    }
}
