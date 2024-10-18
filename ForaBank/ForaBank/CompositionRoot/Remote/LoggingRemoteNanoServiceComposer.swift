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
import SerialComponents

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
    
    typealias MapError<E: Error, F: Error> = (RemoteServiceErrorOf<E>) -> F

    func compose<Payload, Response, MapResponseError: Error, Failure: Error>(
        createRequest: @escaping RemoteDomain<Payload, Response, MapResponseError, Failure>.MakeRequest,
        mapResponse: @escaping RemoteDomain<Payload, Response, MapResponseError, Failure>.MapResponse,
        mapError: @escaping MapError<MapResponseError, Failure>,
        file: StaticString = #file,
        line: UInt = #line
    ) -> RemoteDomain<Payload, Response, MapResponseError, Failure>.Service {
        
        let remote = RemoteService(
            createRequest: logger.decorate(createRequest, with: .network, file: file, line: line),
            httpClient: httpClient,
            mapResponse: logger.decorate(mapResponse: mapResponse, with: .network, file: file, line: line)
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
        createRequest: @escaping RemoteDomain<Payload, Response, MapResponseError, Error>.MakeRequest,
        mapResponse: @escaping RemoteDomain<Payload, Response, MapResponseError, Error>.MapResponse,
        file: StaticString = #file,
        line: UInt = #line
    ) -> RemoteDomain<Payload, Response, MapResponseError, Error>.Service {
        
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

extension LoggingRemoteNanoServiceComposer {
    
    typealias Stamped<T> = SerialComponents.SerialStamped<String, T>
    typealias SerialLoadCompletion<T> = (Stamped<T>?) -> Void
    typealias SerialLoad<T> = (String?, @escaping SerialLoadCompletion<T>) -> Void
    
    func composeSerial<T, MapResponseError: Error>(
        createRequest: @escaping (String?) throws -> URLRequest,
        mapResponse: @escaping (Data, HTTPURLResponse) -> Result<Stamped<T>, MapResponseError>,
        file: StaticString = #file,
        line: UInt = #line
    ) -> SerialLoad<T> {
        
        return { [self] serial, completion in
            
            let createRequest = logger.decorate(createRequest, with: .network, file: file, line: line)
            let mapResponse = logger.decorate(mapResponse: mapResponse, with: .network, file: file, line: line)
            
            do {
                let request = try createRequest(serial)
                
                httpClient.performRequest(request) {
                    
                    switch $0 {
                    case .failure:
                        completion(.none)
                        
                    case let .success((data, response)):
                        switch mapResponse(data, response) {
                        case .failure:
                            completion(.none)
                            
                        case let .success(stamped):
                            if stamped.serial == serial {
                                completion(.none)
                            } else {
                                completion(stamped)
                            }
                        }
                    }
                }
            } catch {
                completion(.none)
            }
        }
    }
}
