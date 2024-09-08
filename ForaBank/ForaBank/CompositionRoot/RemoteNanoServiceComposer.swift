//
//  RemoteNanoServiceComposer.swift
//  ForaBank
//
//  Created by Igor Malyarov on 08.09.2024.
//

import Fetcher
import Foundation
import GenericRemoteService
import RemoteServices

final class RemoteNanoServiceComposer {
    
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

extension RemoteNanoServiceComposer {
    
    typealias NanoService<Payload, Response, Failure: Error> = (Payload, @escaping (Result<Response, Failure>) -> Void) -> Void
    
    func compose<Payload, Response, Failure: Error>(
        createRequest: @escaping (Payload) throws -> URLRequest,
        mapResponse: @escaping (Data, HTTPURLResponse) -> Result<Response, Error>,
        mapError: @escaping (RemoteServiceErrorOf<Error>) -> Failure,
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
    
    func compose<Payload, Response>(
        createRequest: @escaping (Payload) throws -> URLRequest,
        mapResponse: @escaping (Data, HTTPURLResponse) -> Result<Response, Error>
    ) -> NanoService<Payload, Response, Error> {
        
        compose(createRequest: createRequest, mapResponse: mapResponse, mapError: { $0 })
    }
}

// MARK: - Void payload

extension RemoteNanoServiceComposer {
    
    typealias VoidNanoService<Response, Failure: Error> = (@escaping (Result<Response, Failure>) -> Void) -> Void
    
    func compose<Response, Failure: Error>(
        createRequest: @escaping () throws -> URLRequest,
        mapResponse: @escaping (Data, HTTPURLResponse) -> Result<Response, Error>,
        mapError: @escaping (RemoteServiceErrorOf<Error>) -> Failure,
        file: StaticString = #file,
        line: UInt = #line
    ) -> VoidNanoService<Response, Failure> {
        
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
    
    func compose<Response>(
        createRequest: @escaping () throws -> URLRequest,
        mapResponse: @escaping (Data, HTTPURLResponse) -> Result<Response, Error>
    ) -> VoidNanoService<Response, Error> {
        
        compose(createRequest: createRequest, mapResponse: mapResponse, mapError: { $0 })
    }
}
