//
//  CountdownReducer.swift
//
//
//  Created by Igor Malyarov on 19.01.2024.
//

public final class CountdownReducer {
    
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
            state = update(state, with: countdownFailure)
            
        case .prepare:
            effect = prepare(state)
            
        case .start:
            state = start(state)
            
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
    
    func prepare(
        _ state: State
    ) -> Effect? {
        
        var effect: Effect?
        
        switch state {
        case .completed:
            effect = .initiate
            
        case .failure, .running:
            break
        }
        
        return effect
    }
    
    func start(
        _ state: State
    ) -> State {
        
        var state = state
        
        switch state {
        case .completed:
            state = .running(remaining: duration)
            
        case .failure:
            fatalError()
            
        case .running:
            break
        }
        
        return state
    }
    
    func tick(
        _ state: State
    ) -> State {
        
        var state = state
        
        switch state {
        case .completed:
            break
            
        case .failure:
            break
            
        case let .running(remaining: remaining):
            if remaining > 0 {
                state = .running(remaining: remaining - 1)
            } else {
                state = .completed
            }
        }
        
        return state
    }
    
    func update(
        _ state: State,
        with countdownFailure: CountdownFailure
    ) -> State {
        
        var state = state
        
        switch state {
        case .completed:
            state = .failure(countdownFailure)
            
        case .failure(_):
            fatalError()
            
        case .running:
            break
        }
        
        return state
    }
}
