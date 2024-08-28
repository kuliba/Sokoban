//
//  OperationTrackerBinder.swift
//
//
//  Created by Igor Malyarov on 28.08.2024.
//

import Combine
import CombineSchedulers
import Foundation

/// A binder class that connects a client with a stateful operation tracker, managing state transitions and the loading process.
///
/// This class is designed to handle stateful operations in a way that decouples the client from the specifics
/// of the loading mechanism. The `OperationTrackerBinder` is generic over the type of client and the type of response
/// it handles.
///
/// The `scheduler` provided during initialisation does not have to be `DispatchQueue.main` since `OperationTrackerBinder`
/// is not intended for direct use with the UI. However, if this binder is used in a UI context, it is recommended to use
/// `DispatchQueue.main` to ensure UI updates occur on the main thread.
public final class OperationTrackerBinder<Client, T> {
    
    /// The client instance that will receive the loaded data.
    public let client: Client
    
    /// The stateful loader model that manages the state of the loading process.
    public let loader: OperationTrackerModel
    
    /// The cancellable object that manages the subscription to state changes.
    private let cancellable: AnyCancellable
    
    /// Initialises a new instance of `OperationTrackerBinder`.
    ///
    /// - Parameters:
    ///   - load: A closure that defines the loading process. This closure receives a completion handler that should be called
    ///           with the loaded data (or `nil` in case of failure).
    ///   - client: The client instance that will receive the loaded data.
    ///   - receive: A closure that defines how the client should handle the received data. This closure takes the client and
    ///              returns another closure that handles the data.
    ///   - scheduler: The scheduler on which to perform state changes and effects. This does not need to be `DispatchQueue.main`,
    ///                but should be if this binder is used in a UI context.
    public init(
        load: @escaping Load,
        client: Client,
        receive: @escaping Receive,
        scheduler: AnySchedulerOf<DispatchQueue>
    ) {
        self.client = client
        self.loader = .init(load: load, scheduler: scheduler)
        
        self.cancellable = loader.$state
            .eraseToAnyPublisher()
            .perform(load, failureValue: nil)
            .sink(receiveValue: receive(client))
    }
    
    /// A typealias for the closure that defines the loading process.
    ///
    /// The closure takes a completion handler as a parameter. The completion handler should be called with
    /// the loaded data (`T?`), where `nil` indicates a failure to load.
    public typealias Load = (@escaping (T?) -> Void) -> Void
    
    /// A typealias for the closure that defines how the client should handle the received data.
    ///
    /// The closure takes the client instance and returns another closure that handles the data (`T?`).
    public typealias Receive = (Client) -> (T?) -> Void
}

public extension OperationTrackerBinder {
    
    /// Triggers the loading process by sending a load event to the stateful loader.
    ///
    /// This method initiates the loading process managed by the `OperationTrackerModel` by transitioning its state to `.loading`
    /// and subsequently handling the result.
    func load() {
        loader.event(.start)
    }
}
