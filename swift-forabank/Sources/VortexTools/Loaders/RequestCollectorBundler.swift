//
//  RequestCollectorBundler.swift
//
//
//  Created by Igor Malyarov on 25.08.2024.
//

import CombineSchedulers
import Foundation

public final class RequestCollectorBundler<Request, Response>
where Request: Hashable {
    
    private let requestCollector: RequestCollector<Request, Response>
    
    /// Initialises a new instance of `RequestCollectorBundler`.
    ///
    /// This class is responsible for collecting, bundling, and processing requests over a specified period.
    /// It leverages `RequestCollector` to aggregate incoming requests and then utilises `RequestBundler`
    /// to ensure that identical requests are only executed once. After the specified collection period,
    /// the bundled requests are processed and the results are delivered to all relevant completion handlers.
    ///
    /// - Parameters:
    ///   - collectionPeriod: The time interval over which requests are collected before processing.
    ///     During this period, incoming requests are aggregated to be processed together.
    ///   - scheduler: The scheduler that manages the timing of request processing. This allows
    ///     precise control over when the collected requests are processed.
    ///   - performRequest: A closure that performs the actual request and returns the response.
    ///     This closure is used by `RequestBundler` to ensure that each unique request is only performed once.
    public init(
        collectionPeriod: DispatchTimeInterval,
        scheduler: AnySchedulerOf<DispatchQueue>,
        performRequest: @escaping PerformRequest
    ) {
        let bundler = RequestBundler(performRequest: performRequest)
        self.requestCollector = .init(
            collectionPeriod: collectionPeriod,
            performRequests: { requests, completion in
                
                bundler.load(requests: requests) {
                    
                    completion([$0 : $1])
                }
            },
            scheduler: scheduler
        )
    }
    
    /// A typealias for a closure that performs a request and provides the response via a completion handler.
    ///
    /// This closure takes a `Request` as input and an escaping completion handler that returns a `Response`.
    /// The completion handler is expected to be called once the request is fulfilled, providing the appropriate response.
    public typealias PerformRequest = (Request, @escaping (Response) -> Void) -> Void
}

extension RequestCollectorBundler {
    
    /// Processes a new request by first collecting it, then bundling and executing it.
    ///
    /// This method adds the given request to the collection managed by `RequestCollector`. The request will be
    /// aggregated with other requests over the specified collection period. After the collection period ends,
    /// the bundled requests are processed, and the completion handler is called with the response.
    ///
    /// - Parameters:
    ///   - request: The request to be processed.
    ///   - completion: The completion handler to be called with the response. This handler will be
    ///     invoked once the request has been processed, returning the response associated with the request.
    public func process(
        _ request: Request,
        _ completion: @escaping (Response) -> Void
    ) {
        requestCollector.process(request, completion)
    }
}
