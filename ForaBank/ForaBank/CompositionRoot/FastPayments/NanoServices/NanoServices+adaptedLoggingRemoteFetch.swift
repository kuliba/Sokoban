//
//  NanoServices+adaptedLoggingFetch.swift
//  ForaBank
//
//  Created by Igor Malyarov on 03.02.2024.
//

import Fetcher
import Foundation
import GenericRemoteService
import FastPaymentsSettings

extension NanoServices {
    
    typealias Fetch<Input, Output> = (Input, @escaping (Result<Output, ServiceFailure>) -> Void) -> Void
    typealias VoidFetch<Output> = (@escaping (Result<Output, ServiceFailure>) -> Void) -> Void
    typealias MapResponse<T> = (Data, HTTPURLResponse) -> Result<T, FastPaymentsSettings.ResponseMapper.MappingError>
    
    static func adaptedLoggingFetch<Output>(
        createRequest: @escaping () throws -> URLRequest,
        httpClient: HTTPClient,
        mapResponse: @escaping MapResponse<Output>,
        log: @escaping (String, StaticString, UInt) -> Void,
        file: StaticString = #file,
        line: UInt = #line
    ) -> VoidFetch<Output> {
        
        let adapted = adaptedLoggingRemoteService(
            createRequest: createRequest,
            httpClient: httpClient,
            mapResponse: mapResponse,
            log: log,
            file: file,
            line: line
        )
        
        return adapted.fetch(completion:)
    }
    
    static func adaptedLoggingFetch<Input, Output>(
        createRequest: @escaping (Input) throws -> URLRequest,
        httpClient: HTTPClient,
        mapResponse: @escaping MapResponse<Output>,
        log: @escaping (String, StaticString, UInt) -> Void,
        file: StaticString = #file,
        line: UInt = #line
    ) -> Fetch<Input, Output> {
        
        let adapted = adaptedLoggingRemoteService(
            createRequest: createRequest,
            httpClient: httpClient,
            mapResponse: mapResponse,
            log: log,
            file: file,
            line: line
        )
        
        return adapted.fetch(_:completion:)
    }
    
    private static func adaptedLoggingRemoteService<Input, Output>(
        createRequest: @escaping (Input) throws -> URLRequest,
        httpClient: HTTPClient,
        mapResponse: @escaping MapResponse<Output>,
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
    
    init(error: RemoteServiceError<Error, Error, FastPaymentsSettings.ResponseMapper.MappingError>) {
        
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
