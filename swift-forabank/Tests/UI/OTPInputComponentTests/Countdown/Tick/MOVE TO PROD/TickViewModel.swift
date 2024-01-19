//
//  TickViewModel.swift
//  
//
//  Created by Igor Malyarov on 18.01.2024.
//

import OTPInputComponent


import Combine
import Foundation

final class TickViewModel: ObservableObject {
    
    @Published private(set) var state: State
    
    private let stateSubject = PassthroughSubject<State, Never>()
    
    private let timer: TimerProtocol
    private let reduce: Reduce
    private let handleEffect: HandleEffect
    
    init(
        initialState: State,
        timer: TimerProtocol,
        reduce: @escaping Reduce,
        handleEffect: @escaping HandleEffect,
        scheduler: AnySchedulerOfDispatchQueue = .makeMain()
    ) {
        self.state = initialState
        self.timer = timer
        self.reduce = reduce
        self.handleEffect = handleEffect
        
        stateSubject
            .removeDuplicates()
            .receive(on: scheduler)
            .assign(to: &$state)
    }
}

extension TickViewModel {
    
    func event(_ event: Event) {
        
        let (state, effect) = reduce(state, event)
        stateSubject.send(state)
        
        switch state {
        case .running:
            timer.start(every: 1) { [weak self] in self?.event(.tick) }
            
        case .idle:
            timer.stop()
        }
        
        if let effect {
            
            handleEffect(effect) { [weak self] event in
                
                self?.event(event)
            }
        }
#warning("LOOKS LIKE a bug with constant start on every tick")
#warning("ADD TESTS")
//        let (newState, effect) = reduce(state, event)
//            
//            if case .running = newState, case .idle = state {
//                // Start timer only if transitioning from idle to running
//                timer.start(every: 1) { [weak self] in self?.event(.tick) }
//            } else if case .idle = newState, case .running = state {
//                // Stop timer only if transitioning from running to idle
//                timer.stop()
//            }
//            
//            stateSubject.send(newState)
//            state = newState  // Update state
//
//            if let effect = effect {
//                handleEffect(effect) { [weak self] event in
//                    self?.event(event)
//                }
//            }
    }
}

extension TickViewModel {
    
    typealias Reduce = (State, Event) -> (State, Effect?)
    typealias HandleEffect = (Effect, @escaping (Event) -> Void) -> Void
    
    typealias State = TickState
    typealias Event = TickEvent
    typealias Effect = TickEffect
}
