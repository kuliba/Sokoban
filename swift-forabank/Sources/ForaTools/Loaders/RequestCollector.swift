//
//  RequestCollector.swift
//
//
//  Created by Igor Malyarov on 01.07.2024.
//

import CombineSchedulers
import Foundation

// TODO: add request cancellation
/// A class that collects requests and aggregates them over a specified period before processing them.
///
/// - Parameters:
///   - Request: The type of the request. Must conform to `Hashable`.
///   - Response: The type of the response.
public final class RequestCollector<Request, Response>
where Request: Hashable {
    
    /// A dictionary that holds the pending requests and their associated completion handlers.
    private var pendingRequests: Completions
    
    /// A dictionary that holds the inflight requests and their associated completion handlers.
    private var inflightRequests: Completions
    
    /// The time when the first request was received.
    private var startTime: Date?
    
    /// The period over which requests are collected before processing.
    private let collectionPeriod: DispatchTimeInterval
    
    /// A closure that performs the processing of the collected requests.
    private let performRequests: PerformRequests
    
    /// The scheduler used to manage the timing of request processing.
    private let scheduler: AnySchedulerOf<DispatchQueue>
    
    /// A lock to ensure thread safety when accessing or modifying shared state.
    private let lock = NSRecursiveLock()
    
    /// Initialises a new instance of `RequestCollector`.
    ///
    /// - Parameters:
    ///   - pendingRequests: The initial pending requests. Defaults to an empty dictionary.
    ///   - inflightRequests: The initial inflight requests. Defaults to an empty dictionary.
    ///   - startTime: The initial start time. Defaults to `nil`.
    ///   - collectionPeriod: The period over which requests are collected before processing.
    ///   - performRequests: A closure that performs the processing of the collected requests.
    ///   - scheduler: The scheduler used to manage the timing of request processing.
    public init(
        pendingRequests: Completions = .init(),
        inflightRequests: Completions = .init(),
        startTime: Date? = nil,
        collectionPeriod: DispatchTimeInterval,
        performRequests: @escaping PerformRequests,
        scheduler: AnySchedulerOf<DispatchQueue>
    ) {
        self.pendingRequests = pendingRequests
        self.inflightRequests = inflightRequests
        self.startTime = startTime
        self.collectionPeriod = collectionPeriod
        self.performRequests = performRequests
        self.scheduler = scheduler
    }
    
    /// A typealias for the completion handler.
    public typealias Completion = (Response) -> Void
    
    /// A typealias for a dictionary that maps requests to an array of completion handlers.
    public typealias Completions = [Request: [Completion]]
    
    /// A typealias for the completion handler of the perform requests closure.
    public typealias PerformRequestsCompletion = ([Request: Response]) -> Void
    
    /// A typealias for the perform requests closure.
    public typealias PerformRequests = ([Request], @escaping PerformRequestsCompletion) -> Void
}

public extension RequestCollector {
    
    /// Processes a new request.
    /// - Parameters:
    ///   - request: The request to be processed.
    ///   - completion: The completion handler to be called with the response.
    func process(
        _ request: Request,
        _ completion: @escaping Completion
    ) {
        lock.lock()
        defer { lock.unlock() }
        
        if let handlers = inflightRequests[request] {
            inflightRequests[request] = handlers + [completion]
        } else if let handlers = pendingRequests[request] {
            pendingRequests[request] = handlers + [completion]
        } else {
            pendingRequests[request] = [completion]
        }
        
        if startTime == nil {
            
            startTime = Date()
            scheduleCollaboratorInvocation()
        }
    }
}

private extension RequestCollector {
    
    /// Schedules the invocation of the collaborator to process the collected requests.
    func scheduleCollaboratorInvocation() {
        
        scheduler.schedule(
            after: .init(.now().advanced(by: collectionPeriod))
        ) {
            self.processRequests()
        }
    }
    
    /// Processes the collected requests by invoking the collaborator.
    func processRequests() {
        
        lock.lock()
        defer { lock.unlock() }
        
        guard !pendingRequests.isEmpty
        else {
            startTime = nil
            return
        }
        
        let requestsToProcess = Array(pendingRequests.keys)
        inflightRequests = pendingRequests
        pendingRequests.removeAll()
        startTime = nil
        
        performRequests(requestsToProcess, handleResponses)
    }
    
    /// Handles the responses from the collaborator by calling the associated completion handlers.
    /// - Parameter responses: A dictionary mapping requests to their responses.
    func handleResponses(responses: [Request: Response]) {
        
        for (request, response) in responses {
            
            if let handlers = inflightRequests[request] {
                
                for handler in handlers {
                    handler(response)
                }
                inflightRequests.removeValue(forKey: request)
            }
        }
    }
}
