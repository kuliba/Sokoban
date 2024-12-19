//
//  OperationTrackerBinder.swift
//
//
//  Created by Igor Malyarov on 28.08.2024.
//

import Combine
import CombineSchedulers
import Foundation

/// A binder class that connects a client with a stateful operation tracker, managing state transitions and operations.
///
/// This class is designed to handle stateful operations in a way that decouples the client from the specifics
/// of the operation mechanism. The `OperationTrackerBinder` is generic over the type of client and the type of response
/// it handles.
///
/// The `scheduler` provided during initialisation does not have to be `DispatchQueue.main` since `OperationTrackerBinder`
/// is not intended for direct use with the UI. However, if this binder is used in a UI context, it is recommended to use
/// `DispatchQueue.main` to ensure UI updates occur on the main thread.
public final class OperationTrackerBinder<Client, T> {
    
    /// The client instance that will receive the operation result.
    public let client: Client
    
    /// The stateful tracker model that manages the state of the operation.
    public let tracker: OperationTrackerModel
    
    /// The cancellable object that manages the subscription to state changes.
    private let cancellable: AnyCancellable
    
    /// Initialises a new instance of `OperationTrackerBinder`.
    ///
    /// - Parameters:
    ///   - start: A closure that defines the operation process. This closure receives a completion handler that should be called
    ///            with the result (or `nil` in case of failure).
    ///   - client: The client instance that will receive the operation result.
    ///   - receive: A closure that defines how the client should handle the received result. This closure takes the client and
    ///              returns another closure that handles the result.
    ///   - scheduler: The scheduler on which to perform state changes and effects. This does not need to be `DispatchQueue.main`,
    ///                but should be if this binder is used in a UI context.
    public init(
        start: @escaping Start,
        client: Client,
        receive: @escaping Receive,
        scheduler: AnySchedulerOf<DispatchQueue>
    ) {
        self.client = client
        self.tracker = .init(start: start, scheduler: scheduler)
        
        self.cancellable = tracker.$state
            .eraseToAnyPublisher()
            .perform(start, failureValue: nil)
            .sink(receiveValue: receive(client))
    }
    
    /// A typealias for the closure that defines the operation process.
    ///
    /// The closure takes a completion handler as a parameter. The completion handler should be called with
    /// the result (`T?`), where `nil` indicates a failure to complete the operation.
    public typealias Start = (@escaping (T?) -> Void) -> Void
    
    /// A typealias for the closure that defines how the client should handle the received result.
    ///
    /// The closure takes the client instance and returns another closure that handles the result (`T?`).
    public typealias Receive = (Client) -> (T?) -> Void
}

public extension OperationTrackerBinder {
    
    /// Triggers the operation process by sending a start event to the stateful tracker.
    ///
    /// This method initiates the operation process managed by the `OperationTrackerModel` by transitioning its state to `.inflight`
    /// and subsequently handling the result.
    func start() {
        
        tracker.event(.start)
    }
}
