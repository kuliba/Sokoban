//
//  NanoServices+adaptedLoggingRemoteService.swift
//  ForaBank
//
//  Created by Igor Malyarov on 03.02.2024.
//

import Fetcher
import Foundation
import GenericRemoteService
import FastPaymentsSettings

extension NanoServices {
    
    static func adaptedLoggingRemoteService<Input, Output>(
        createRequest: @escaping (Input) throws -> URLRequest,
        httpClient: HTTPClient,
        mapResponse: @escaping (Data, HTTPURLResponse) -> Result<Output, MappingError>,
        log: @escaping (String, StaticString, UInt) -> Void,
        file: StaticString = #file,
        line: UInt = #line
    ) -> any Fetcher<Input, Output, ServiceFailure> {
        
        let loggingRemoteService = LoggingRemoteServiceDecorator(
            createRequest: createRequest,
            performRequest: httpClient.performRequest(_:completion:),
            mapResponse: mapResponse,
            log: log,
            file: file,
            line: line
        ).remoteService
        
        let adapted = FetchAdapter(
            fetch: loggingRemoteService.fetch(_:completion:),
            mapError: ServiceFailure.init(error:)
        )

        return adapted
    }
}

extension ServiceFailure {
    
    init(error: RemoteServiceError<Error, Error, MappingError>) {
        
        switch error {
        case .createRequest, .performRequest:
            self = .connectivityError
            
        case let .mapResponse(mapResponseError):
            switch mapResponseError {
            case .invalid:
                self = .connectivityError
                
            case let .server(_, errorMessage):
                self = .serverError(errorMessage)
            }
        }
    }
}
