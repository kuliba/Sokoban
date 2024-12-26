//
//  RxViewModel.swift
//
//
//  Created by Igor Malyarov on 14.01.2024.
//

import Combine
import Foundation
import VortexTools

/// A reactive view model for state management with event-driven updates and side effects.
public final class RxViewModel<State, Event, Effect>: ObservableObject {
    
    /// The current state of the view model, updated based on events and effects.
    @Published public private(set) var state: State
    
    private let reduce: Reduce
    private let handleEffect: HandleEffect
    
    private let predicate: Predicate
    private let scheduler: AnySchedulerOfDispatchQueue
    private let eventQueue = PassthroughSubject<Event, Never>()
    private var cancellables = Set<AnyCancellable>()
    
    /// Initializes the view model.
    /// - Parameters:
    ///   - initialState: The initial state of the view model.
    ///   - reduce: A closure that computes a new state and an optional effect from the current state and an event.
    ///   - handleEffect: A closure that processes effects and emits new events.
    ///   - predicate: A closure to determine if a state update should be skipped. Defaults to always allowing updates.
    ///   - scheduler: The scheduler on which events and effects are processed. Defaults to `.main`.
    public init(
        initialState: State,
        reduce: @escaping Reduce,
        handleEffect: @escaping HandleEffect,
        predicate: @escaping Predicate = { _,_ in false },
        scheduler: AnySchedulerOfDispatchQueue = .makeMain()
    ) {
        self.state = initialState
        self.reduce = reduce
        self.handleEffect = handleEffect
        self.predicate = predicate
        self.scheduler = scheduler
        
        eventQueue
            .receive(on: scheduler)
            .sink { [weak self] in self?.processEvent($0) }
            .store(in: &cancellables)
    }
    
    /// Processes an incoming event.
    /// - Parameter event: The event to process.
    private func processEvent(_ event: Event) {
        
        let (newState, effect) = self.reduce(state, event)
        
        if !predicate(state, newState) {
            
            state = newState
        }
        
        if let effect {
            
            handleEffect(effect) { [weak self] in
                
                self?.eventQueue.send($0)
            }
        }
    }
}

public extension RxViewModel {
    
    /// Sends an event to the view model for processing.
    /// - Parameter event: The event to process.
    func event(_ event: Event) {
        
        eventQueue.send(event)
    }
}

public extension RxViewModel {
    
    /// A closure that computes a new state and an optional effect based on the current state and an event.
    typealias Reduce = (State, Event) -> (State, Effect?)
    
    /// A closure that handles effects and emits subsequent events.
    typealias HandleEffect = (Effect, @escaping (Event) -> Void) -> Void
    
    /// A closure that determines whether a state update should be skipped.
    /// - Parameters:
    ///   - oldState: The current state before the event is processed.
    ///   - newState: The newly computed state after the event is processed.
    /// - Returns: `true` if the state update should be skipped; otherwise, `false`.
    typealias Predicate = (State, State) -> Bool
}
