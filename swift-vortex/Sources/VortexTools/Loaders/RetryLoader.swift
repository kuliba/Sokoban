//
//  RetryLoader.swift
//
//
//  Created by Igor Malyarov on 24.06.2024.
//

import Foundation

/// A loader that retries the load operation a specified number of times in case of failure, with a customisable retry strategy.
public final class RetryLoader<Payload, Response, Failure>
where Failure: Error {
    
    private let performer: any Performer
    private let getRetryIntervals: GetRetryIntervals
    private let scheduler: AnySchedulerOfDispatchQueue
    
    /// Initialises a new instance of `RetryLoader`.
    ///
    /// - Parameters:
    ///   - performer: The loader to be decorated with retry logic.
    ///   - getRetryIntervals: A closure that returns an array of retry intervals based on the payload.
    ///   - scheduler: A scheduler for managing the retry timing.
    public init(
        performer: any Performer,
        getRetryIntervals: @escaping GetRetryIntervals,
        scheduler: AnySchedulerOfDispatchQueue
    ) {
        self.performer = performer
        self.getRetryIntervals = getRetryIntervals
        self.scheduler = scheduler
    }
    
    public typealias Performer = Loader<Payload, LoadResult>
    public typealias LoadResult = Result<Response, Failure>
    public typealias GetRetryIntervals = (Payload) -> [DispatchTimeInterval]
}

extension RetryLoader: Loader {
    
    /// Loads the specified payload, retrying the operation if it fails.
    ///
    /// - Parameters:
    ///   - payload: The payload to be loaded.
    ///   - completion: The completion handler to be called with the result of the loading operation.
    public func load(
        _ payload: Payload,
        _ completion: @escaping (LoadResult) -> Void
    ) {
        let retryIntervals = getRetryIntervals(payload)
        load(payload, with: retryIntervals, completion)
    }
}

private extension RetryLoader {
    
    /// Attempts to load the specified payload, retrying the operation according to the provided intervals.
    ///
    /// - Parameters:
    ///   - payload: The payload to be loaded.
    ///   - retryIntervals: An array of intervals to wait before each retry attempt.
    ///   - completion: The completion handler to be called with the result of the loading operation.
    func load(
        _ payload: Payload,
        with retryIntervals: [DispatchTimeInterval],
        _ completion: @escaping (LoadResult) -> Void
    ) {
        performer.load(payload) { [weak self] in
            
            guard let self else { return }
            
            switch $0 {
            case let .failure(failure):
                if retryIntervals.isEmpty {
                    completion(.failure(failure))
                } else {
                    var remainingIntervals = retryIntervals
                    let nextInterval = remainingIntervals.removeFirst()
                    
                    scheduler.schedule(
                        after: .init(.now() + nextInterval)
                    ) { [weak self] in
                        
                        self?.load(payload, with: remainingIntervals, completion)
                    }
                }
                
            case let .success(response):
                completion(.success(response))
            }
        }
    }
}
