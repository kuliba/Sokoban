//
//  StateValueBinder.swift
//
//
//  Created by Igor Malyarov on 28.08.2024.
//

import Combine

/// A class that binds a `State` publisher to a `Value` receiver, processing the state to produce the value.
public final class StateValueBinder<State, Value> {
    
    /// The publisher that emits `State` values.
    private let publisher: AnyPublisher<State, Never>
    
    /// A closure that processes the `State` and produces a `Value`, which is then passed to the receiver.
    private let process: Process
    
    /// A closure that receives the `Value` produced by the `process` closure.
    private let receive: Receive
    
    /// Initialises the `StateValueBinder` with a publisher, process closure, and receive closure.
    ///
    /// - Parameters:
    ///   - publisher: A publisher that emits `State` values.
    ///   - process: A closure that processes the emitted `State` and produces a `Value`.
    ///   - receive: A closure that handles the `Value` produced by the `process` closure.
    public init(
        publisher: AnyPublisher<State, Never>,
        process: @escaping Process,
        receive: @escaping Receive
    ) {
        self.publisher = publisher
        self.process = process
        self.receive = receive
    }
    
    /// A type alias for the process closure.
    /// The closure takes a `State` and a completion handler that it calls with a `Value`.
    public typealias Process = (State, @escaping (Value) -> Void) -> Void
    
    /// A type alias for the receive closure.
    /// The closure takes a `Value` produced by the `process` closure.
    public typealias Receive = (Value) -> Void
}

public extension StateValueBinder {
    
    /// Starts the binding process, subscribing to the `State` publisher, processing each emitted state,
    /// and passing the resulting `Value` to the receive closure.
    ///
    /// - Returns: An `AnyCancellable` instance that represents the subscription. You must retain
    ///            this to keep the subscription alive.
    func bind() -> AnyCancellable {
        
        publisher
            .flatMap { state in
                
                AnyPublisher { self.process(state, $0) }
            }
            .sink(receiveValue: receive)
    }
}
