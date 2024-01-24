//
//  CountdownReducer.swift
//
//
//  Created by Igor Malyarov on 19.01.2024.
//

public final class CountdownReducer {
#warning("improve duration with Tagged")
    private let duration: Int
    
    public init(duration: Int) {
        
        self.duration = duration
    }
}

public extension CountdownReducer {
    
    func reduce(
        _ state: State,
        _ event: Event
    ) -> (State, Effect?) {
        
        var state = state
        var effect: Effect?
        
        switch event {
        case let .failure(countdownFailure):
            if case .completed = state {
                state = .failure(countdownFailure)
            }
            
        case .prepare:
            if case .completed = state {
                effect = .initiate
            }
            
        case .start:
            if case .completed = state {
                state = .starting(duration: duration)
            }
            
        case .tick:
            state = tick(state)
        }
        
        return (state, effect)
    }
}

public extension CountdownReducer {
    
    typealias State = CountdownState
    typealias Event = CountdownEvent
    typealias Effect = CountdownEffect
}

private extension CountdownReducer {
    
    func tick(
        _ state: State
    ) -> State {
        
        var state = state
        
        switch state {
        case .completed, .failure:
            break
            
        case let .running(remaining: remaining):
            if remaining > 0 {
                state = .running(remaining: remaining - 1)
            } else {
                state = .completed
            }
            
        case .starting:
            state = .running(remaining: duration - 1)
        }
        
        return state
    }
}
