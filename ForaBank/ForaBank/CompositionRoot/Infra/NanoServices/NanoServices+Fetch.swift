//
//  NanoServices+Fetch.swift
//  ForaBank
//
//  Created by Igor Malyarov on 07.02.2024.
//

import Fetcher
import Foundation

extension NanoServices {
    
    typealias MapResponse<T, Failure: Error> = (Data, HTTPURLResponse) -> Result<T, Failure>
    typealias MapError<MappingError: Error, Failure: Error> = (RemoteServiceErrorOf<MappingError>) -> Failure
    typealias Fetch<Input, Output, Failure: Error> = (Input, @escaping (Result<Output, Failure>) -> Void) -> Void
    typealias VoidFetch<Output, Failure: Error> = (@escaping (Result<Output, Failure>) -> Void) -> Void
    
    static func adaptedLoggingFetch<Input, Output, MappingError: Error, Failure: Error>(
        createRequest: @escaping (Input) throws -> URLRequest,
        httpClient: HTTPClient,
        mapResponse: @escaping MapResponse<Output, MappingError>,
        mapError: @escaping MapError<MappingError, Failure>,
        log: @escaping (String, StaticString, UInt) -> Void,
        file: StaticString = #file,
        line: UInt = #line
    ) -> Fetch<Input, Output, Failure> {
        
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
            mapError: mapError
        )
        
        return adapted.fetch(_:completion:)
    }
    
    static func adaptedLoggingFetch<Input, Output, NewOutput, MappingError: Error, Failure: Error>(
        createRequest: @escaping (Input) throws -> URLRequest,
        httpClient: HTTPClient,
        mapResponse: @escaping MapResponse<Output, MappingError>,
        mapOutput: @escaping (Output) -> NewOutput,
        mapError: @escaping MapError<MappingError, Failure>,
        log: @escaping (String, StaticString, UInt) -> Void,
        file: StaticString = #file,
        line: UInt = #line
    ) -> Fetch<Input, NewOutput, Failure> {
        
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
            map: mapOutput,
            mapError: mapError
        )
        
        return adapted.fetch(_:completion:)
    }
    
    static func adaptedLoggingFetch<Output, MappingError: Error, Failure: Error>(
        createRequest: @escaping () throws -> URLRequest,
        httpClient: HTTPClient,
        mapResponse: @escaping MapResponse<Output, MappingError>,
        mapError: @escaping MapError<MappingError, Failure>,
        log: @escaping (String, StaticString, UInt) -> Void,
        file: StaticString = #file,
        line: UInt = #line
    ) -> VoidFetch<Output, Failure> {
        
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
            mapError: mapError
        )
        
        return adapted.fetch(completion:)
    }
    
    static func adaptedLoggingFetch<Output, NewOutput, MappingError: Error, Failure: Error>(
        createRequest: @escaping () throws -> URLRequest,
        httpClient: HTTPClient,
        mapResponse: @escaping MapResponse<Output, MappingError>,
        mapOutput: @escaping (Output) -> NewOutput,
        mapError: @escaping MapError<MappingError, Failure>,
        log: @escaping (String, StaticString, UInt) -> Void,
        file: StaticString = #file,
        line: UInt = #line
    ) -> VoidFetch<NewOutput, Failure> {
        
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
            map: mapOutput,
            mapError: mapError
        )
        
        return adapted.fetch(completion:)
    }
    
    static func adaptedLoggingFetch<Output, NewOutput, MappingError: Error, Failure: Error>(
        createRequest: @escaping () throws -> URLRequest,
        httpClient: HTTPClient,
        mapResponse: @escaping MapResponse<Output, MappingError>,
        mapResult: @escaping (Result<Output, RemoteServiceErrorOf<MappingError>>) -> Result<NewOutput, Failure>,
        log: @escaping (String, StaticString, UInt) -> Void,
        file: StaticString = #file,
        line: UInt = #line
    ) -> VoidFetch<NewOutput, Failure> {
        
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
            mapResult: mapResult
        )
        
        return adapted.fetch(completion:)
    }
    
    static func adaptedLoggingRemoteService<Input, Output, MappingError: Error, Failure: Error>(
        createRequest: @escaping (Input) throws -> URLRequest,
        httpClient: HTTPClient,
        mapResponse: @escaping MapResponse<Output, MappingError>,
        mapError: @escaping MapError<MappingError, Failure>,
        log: @escaping (String, StaticString, UInt) -> Void,
        file: StaticString = #file,
        line: UInt = #line
    ) -> any Fetcher<Input, Output, Failure> {
        
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
            mapError: mapError
        )
        
        return adapted
    }
}
