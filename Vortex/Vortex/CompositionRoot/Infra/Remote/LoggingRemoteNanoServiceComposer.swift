//
//  LoggingRemoteNanoServiceComposer.swift
//  Vortex
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
    
    /// A typealias representing a stamped value with a `String` serial and a value of type `T`.
    typealias Stamped<T> = SerialComponents.SerialStamped<String, T>
    
    /// A closure type representing a completion handler that provides an optional `Stamped<T>`.
    /// The completion handler receives a `Stamped<T>` if new data is available (i.e., the serial has changed),
    /// or `nil` if no new data is available or an error occurred.
    typealias SerialLoadCompletion<T> = (Stamped<T>?) -> Void
    
    /// A closure type representing a function that takes an optional `String` serial and a completion handler.
    typealias SerialLoad<T> = (String?, @escaping SerialLoadCompletion<T>) -> Void
    
    /// Composes a serial loading function with logging and error handling.
    ///
    /// This method creates a `SerialLoad<T>` closure that, when called, will:
    /// - Create a `URLRequest` using the provided `createRequest` closure and the given serial.
    /// - Perform the network request using `httpClient`.
    /// - Map the response data to a `Stamped<T>` using the provided `mapResponse` closure.
    /// - Check if the returned serial is **different** from the input serial.
    /// - If the serials are different (indicating new data), it invokes the completion handler with the `Stamped<T>`.
    /// - If the serials are the same or any error occurs during the process, it invokes the completion handler with `nil`.
    ///
    /// This behaviour ensures that the caller is only notified when new data is available,
    /// and it does not concern itself with the reasons for failure (hence the optional completion parameter).
    ///
    /// - Parameters:
    ///   - createRequest: A closure that takes an optional `String` serial and returns a `URLRequest` or throws an error.
    ///   - mapResponse: A closure that takes `Data` and `HTTPURLResponse` and returns a `Result<Stamped<T>, MapResponseError>`.
    ///   - file: The file from which this function is called (for logging purposes). Defaults to the current file.
    ///   - line: The line number from which this function is called (for logging purposes). Defaults to the current line.
    /// - Returns: A `SerialLoad<T>` closure that can be called with a serial and a completion handler.
    func composeSerialLoad<T, MapResponseError: Error>(
        createRequest: @escaping (String?) throws -> URLRequest,
        mapResponse: @escaping (Data, HTTPURLResponse) -> Result<Stamped<T>, MapResponseError>,
        file: StaticString = #file,
        line: UInt = #line
    ) -> SerialLoad<T> {
        
        return { [self] serial, completion in
            
            let createRequest = logger.decorate(createRequest, with: .network, file: file, line: line)
            let mapResponse = logger.decorate(mapResponse: mapResponse, with: .network, file: file, line: line)
            
            guard let request = try? createRequest(serial)
            else {
                // Invoke the completion with nil if an error occurs during request creation
                return completion(nil)
            }
            
            let lastPathComponent = request.url?.lastPathComponent ?? ""
            
            httpClient.performRequest(request) { [logger] result in
                
                switch result {
                case let .failure(failure):
                    logger.log(level: .error, category: .network, message: "Perform request \(lastPathComponent) failure: \(failure).", file: file, line: line)
                    completion(nil)
                    
                case let .success((data, response)):
                    switch mapResponse(data, response) {
                    case .failure:
                        completion(nil)
                        
                    case let .success(stamped):
                        // Check if the stamped serial is different from the input serial
                        if stamped.serial == serial {
                            logger.log(level: .info, category: .network, message: "Response for \(lastPathComponent) has same serial.", file: file, line: line)
                            // If serials are the same, invoke the completion with nil
                            completion(nil)
                        } else {
                            logger.log(level: .info, category: .network, message: "Response for \(lastPathComponent) has different serial.", file: file, line: line)
                            // If serials are different, invoke the completion with the new stamped value
                            completion(stamped)
                        }
                    }
                }
            }
        }
    }
    
    /// A closure type representing a completion handler that provides an optional `Stamped<T>`.
    /// The completion handler receives a `Stamped<T>` if new data is available (i.e., the serial has changed),
    /// or `nil` if no new data is available or an error occurred.
    typealias SerialResultLoadCompletion<T> = (Result<Stamped<T>, Error>) -> Void
    
    /// A closure type representing a function that takes an optional `String` serial and a completion handler.
    typealias SerialResultLoad<T> = (String?, @escaping SerialResultLoadCompletion<T>) -> Void
    
    func composeSerialResultLoad<T, MapResponseError: Error>(
        createRequest: @escaping (String?) throws -> URLRequest,
        mapResponse: @escaping (Data, HTTPURLResponse) -> Result<Stamped<T>, MapResponseError>,
        file: StaticString = #file,
        line: UInt = #line
    ) -> SerialResultLoad<T> {
        
        return { [weak self] serial, completion in
            
            guard let self else { return completion(.failure(SerialResultLoadError.deallocatedSelf)) }
            
            let createRequest = logger.decorate(createRequest, with: .network, file: file, line: line)
            let mapResponse = logger.decorate(mapResponse: mapResponse, with: .network, file: file, line: line)
            
            guard let request = try? createRequest(serial)
            else {
                // Invoke the completion with nil if an error occurs during request creation
                return completion(.failure(SerialResultLoadError.urlRequestCreationFailure))
            }
            
            let lastPathComponent = request.url?.lastPathComponent ?? ""
            
            httpClient.performRequest(request) { [logger] result in
                
                switch result {
                case let .failure(failure):
                    logger.log(level: .error, category: .network, message: "Perform request \(lastPathComponent) failure: \(failure).", file: file, line: line)
                    completion(.failure(SerialResultLoadError.performRequestFailure))
                    
                case let .success((data, response)):
                    switch mapResponse(data, response) {
                    case .failure:
                        completion(.failure(SerialResultLoadError.mapResponseFailure))
                        
                    case let .success(stamped):
                        // Check if the stamped serial is different from the input serial
                        if stamped.serial == serial {
                            logger.log(level: .info, category: .network, message: "Response for \(lastPathComponent) has same serial.", file: file, line: line)
                            // If serials are the same, invoke the completion with failure
                            completion(.failure(SerialResultLoadError.noNewDataFailure))
                        } else {
                            logger.log(level: .info, category: .network, message: "Response for \(lastPathComponent) has different serial.", file: file, line: line)
                            // If serials are different, invoke the completion with the new stamped value
                            completion(.success(stamped))
                        }
                    }
                }
            }
        }
    }
    
    enum SerialResultLoadError: Error {
        
        case deallocatedSelf
        case mapResponseFailure
        case noNewDataFailure
        case performRequestFailure
        case urlRequestCreationFailure
    }
}
