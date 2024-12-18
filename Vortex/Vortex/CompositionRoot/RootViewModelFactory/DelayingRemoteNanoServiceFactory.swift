//
//  DelayingRemoteNanoServiceFactory.swift
//  Vortex
//
//  Created by Igor Malyarov on 10.12.2024.
//

import CombineSchedulers
import Foundation
import RemoteServices

// TODO: - add tests
/// A factory that wraps `RemoteNanoServiceFactory` to introduce a delay in service completion.
final class DelayingRemoteNanoServiceFactory {
    
    private let delay: DispatchQueue.SchedulerTimeType.Stride
    private let factory: RemoteNanoServiceFactory
    private let scheduler: AnySchedulerOf<DispatchQueue>
    
    /// Initializes a delaying service factory.
    ///
    /// - Parameters:
    ///   - delay: The duration to delay service completion.
    ///   - factory: The base service factory to wrap.
    ///   - scheduler: The scheduler used to apply the delay.
    init(
        delay: DispatchQueue.SchedulerTimeType.Stride,
        factory: RemoteNanoServiceFactory,
        scheduler: AnySchedulerOf<DispatchQueue>
    ) {
        self.delay = delay
        self.factory = factory
        self.scheduler = scheduler
    }
}

extension DelayingRemoteNanoServiceFactory: RemoteNanoServiceFactory {
    
    typealias MappingError = RemoteServices.ResponseMapper.MappingError
    
    /// Composes a remote domain service with an added delay on completion.
    ///
    /// - Parameters:
    ///   - makeRequest: The function that performs the request.
    ///   - mapResponse: The function that maps the response.
    /// - Returns: A service that delays completion of its results.
    func compose<Payload, Response>(
        makeRequest: @escaping RemoteDomain<Payload, Response, MappingError, Error>.MakeRequest,
        mapResponse: @escaping RemoteDomain<Payload, Response, MappingError, Error>.MapResponse
    ) -> RemoteDomain<Payload, Response, MappingError, Error>.Service {
        
        let service = factory.compose(makeRequest: makeRequest, mapResponse: mapResponse)
        
        return { [service] payload, completion in
            
            service(payload) { [weak self] result in
                
                guard let self else {
                    
                    return completion(.failure(FactoryDeallocated()))
                }
                
                scheduler.delay(for: delay) { completion(result); _ = service }
            }
        }
    }
    
    /// An error indicating that the factory was deallocated before the service completed.
    struct FactoryDeallocated: Error {}
}

private extension AnySchedulerOf<DispatchQueue> {
    
    /// Delays execution of a closure by a specified timeout.
    ///
    /// - Parameters:
    ///   - timeout: The delay duration.
    ///   - action: The closure to execute after the delay.
    func delay(
        for timeout: Delay,
        _ action: @escaping () -> Void
    ) {
        schedule(after: .init(.init(uptimeNanoseconds: 0)).advanced(by: timeout), action)
    }
    
    typealias Delay = DispatchQueue.SchedulerTimeType.Stride
}
