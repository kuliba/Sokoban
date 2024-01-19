//
//  TickViewModel.swift
//  
//
//  Created by Igor Malyarov on 18.01.2024.
//

import Foundation

import Combine

protocol TimerProtocol {
    
    func start(
        every interval: TimeInterval,
        onRun: @escaping () -> Void
    )
    func stop()
}

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
    }
}

extension TickViewModel {
    
    typealias Reduce = (State, Event) -> (State, Effect?)
    typealias HandleEffect = (Effect, @escaping (Event) -> Void) -> Void
    
    typealias State = TickState
    typealias Event = TickEvent
    typealias Effect = TickEffect
}
