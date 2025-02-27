//
//  RootViewModelFactory+onBackground.swift
//  Vortex
//
//  Created by Igor Malyarov on 08.02.2025.
//

extension RemoteDomainOf where Payload == Void {
    
    /// A service that performs a network request without requiring a payload.
    ///
    /// This service executes the network request and invokes the given completion handler
    /// with a `Result` that contains either a mapped `Response` or a `Failure` error.
    typealias VoidService = (@escaping (Result<Response, Failure>) -> Void) -> Void
}

extension RootViewModelFactory {
    
    /// Creates a remote service that executes on a background scheduler.
    ///
    /// The returned service:
    /// - Schedules the network request on the background scheduler.
    /// - Invokes the provided completion handler with the service result.
    ///
    /// - Parameters:
    ///   - makeRequest: Closure that creates a URLRequest from the payload.
    ///   - mapResponse: Closure that maps raw response data to a typed response.
    /// - Returns: A remote service function that accepts a payload and a completion handler.
    @inlinable
    func onBackground<Payload, Response>(
        makeRequest: @escaping RemoteDomainOf<Payload, Response, Error>.MakeRequest,
        mapResponse: @escaping RemoteDomainOf<Payload, Response, Error>.MapResponse
    ) -> RemoteDomainOf<Payload, Response, Error>.Service {
        
        let service = nanoServiceComposer.compose(makeRequest: makeRequest, mapResponse: mapResponse)
        
        return { [weak self] payload, completion in
            
            self?.schedulers.background.schedule {
                
                service(payload) { [service] in
                    
                    completion($0)
                    _ = service
                }
            }
        }
    }
    
    /// Creates a void payload remote service that executes on a background scheduler.
    ///
    /// - Parameters:
    ///   - makeRequest: Closure that creates a URLRequest.
    ///   - mapResponse: Closure that maps raw response data to a typed response.
    /// - Returns: A remote service function that requires no payload.
    @inlinable
    func onBackground<Response>(
        makeRequest: @escaping RemoteDomainOf<Void, Response, Error>.MakeRequest,
        mapResponse: @escaping RemoteDomainOf<Void, Response, Error>.MapResponse
    ) -> RemoteDomainOf<Void, Response, Error>.VoidService {
        
        let service: RemoteDomainOf<Void, Response, Error>.Service = onBackground(makeRequest: makeRequest, mapResponse: mapResponse)
        
        return { service((), $0) }
    }
}

extension RootViewModelFactory {
    
    /// Creates a remote service that executes on a background scheduler and maps errors to `BackendFailure`.
    ///
    /// The returned service:
    /// - Schedules the network request on the background scheduler.
    /// - Invokes the provided completion handler with the service result.
    /// - Maps any encountered error into a `BackendFailure` using the provided connectivity failure message.
    ///
    /// - Parameters:
    ///   - makeRequest: Closure that creates a URLRequest from the payload.
    ///   - mapResponse: Closure that maps raw response data to a typed response.
    ///   - connectivityFailureMessage: The message to use when converting errors into a connectivity failure.
    /// - Returns: A remote service function that accepts a payload and a completion handler returning a result with a `BackendFailure` error type.
    @inlinable
    func onBackground<Payload, Response>(
        makeRequest: @escaping RemoteDomainOf<Payload, Response, Error>.MakeRequest,
        mapResponse: @escaping RemoteDomainOf<Payload, Response, Error>.MapResponse,
        connectivityFailureMessage: String
    ) -> RemoteDomainOf<Payload, Response, BackendFailure>.Service {
        
        let service = nanoServiceComposer.compose(makeRequest: makeRequest, mapResponse: mapResponse)
        
        return { [weak self] payload, completion in
            
            self?.schedulers.background.schedule {
                
                service(payload) { [service] in
                    
                    let result = $0.mapError {
                        
                        $0.backendFailure(
                            connectivityMessage: connectivityFailureMessage
                        )
                    }
                    
                    completion(result)
                    _ = service
                }
            }
        }
    }
}

extension Error {
    
    /// Converts the current error into a `BackendFailure`.
    ///
    /// If the error is already a `BackendFailure`, it is returned unchanged.
    /// Otherwise, a connectivity failure is returned using the provided message.
    ///
    /// - Parameter connectivityMessage: The connectivity failure message to use if the error is not already a `BackendFailure`.
    /// - Returns: A `BackendFailure` representing the error.
    func backendFailure(
        connectivityMessage: String
    ) -> BackendFailure {
        
        return (self as? BackendFailure) ?? .connectivity(connectivityMessage)
    }
}
