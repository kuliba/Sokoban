//
//  LoggingRemoteNanoServiceComposer.swift
//  ForaBank
//
//  Created by Igor Malyarov on 08.09.2024.
//

import Fetcher
import Foundation
import GenericRemoteService
import RemoteServices

final class LoggingRemoteNanoServiceComposer {
    
    private let httpClient: HTTPClient
    private let logger: LoggerAgentProtocol
    
    init(
        httpClient: HTTPClient,
        logger: LoggerAgentProtocol
    ) {
        self.httpClient = httpClient
        self.logger = logger
    }
}

extension LoggingRemoteNanoServiceComposer {
    
    typealias NanoService<Payload, Response, Failure: Error> = (Payload, @escaping (Result<Response, Failure>) -> Void) -> Void
    typealias CreateRequest<Payload> = (Payload) throws -> URLRequest
    typealias MapResponse<Response, Failure: Error> = (Data, HTTPURLResponse) -> Result<Response, Failure>
    typealias MapError<E: Error, F: Error> = (RemoteServiceErrorOf<E>) -> F

    func compose<Payload, Response, MapResponseError: Error, Failure: Error>(
        createRequest: @escaping CreateRequest<Payload>,
        mapResponse: @escaping MapResponse<Response, MapResponseError>,
        mapError: @escaping MapError<MapResponseError, Failure>,
        file: StaticString = #file,
        line: UInt = #line
    ) -> NanoService<Payload, Response, Failure> {
        
        let remote = RemoteService(
            createRequest: logger.decorate(createRequest, with: .network, file: file, line: line),
            httpClient: httpClient,
            mapResponse: logger.decorate(f: mapResponse, with: .network, file: file, line: line)
        )
        let adapted = FetchAdapter(
            fetch: remote.process(_:completion:),
            mapError: mapError
        )
        
        return adapted.fetch
    }
}

extension LoggingRemoteNanoServiceComposer {

    // TODO: replace with `RemoteNanoServiceFactory` conformance
    func compose<Payload, Response, MapResponseError: Error>(
        createRequest: @escaping CreateRequest<Payload>,
        mapResponse: @escaping MapResponse<Response, MapResponseError>,
        file: StaticString = #file,
        line: UInt = #line
    ) -> NanoService<Payload, Response, Error> {
        
        let remote = RemoteService(
            createRequest: logger.decorate(createRequest, with: .network, file: file, line: line),
            httpClient: httpClient,
            mapResponse: logger.decorate(f: mapResponse, with: .network, file: file, line: line)
        )
        let mapError: MapError<MapResponseError, Error> = { $0 }
        let adapted = FetchAdapter(
            fetch: remote.process(_:completion:),
            mapError: mapError
        )
        
        return adapted.fetch
    }
}
