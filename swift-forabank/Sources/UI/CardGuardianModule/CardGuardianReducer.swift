//
//  CardGuardianReducer.swift
//
//
//  Created by Andryusina Nataly on 06.02.2024.
//

import Foundation

public final class CardGuardianReducer {
    
    public init() {}
}

public extension CardGuardianReducer {
 
#warning("add tests")
    func reduce(
        _ state: State,
        _ event: Event
    ) -> (State, Effect?) {
        
        var state = state
        
        switch event {
            
        case .appear:
            state.updateEvent(.appear)
            
        case let .buttonTapped(tap):
            switch tap {
                
            case .toggleLock:
                state.updateEvent(.buttonTapped(.toggleLock))
                
            case .changePin:
                state.updateEvent(.buttonTapped(.changePin))
                
            case .showOnMain:
                state.updateEvent(.buttonTapped(.showOnMain))
            }
        }
#warning("delete!!! only for tests")
        switch state.event {
            
        case .none:
            print("none")
            
        case let .some(event):
            switch event {
                
            case .appear:
                print("appear")
                
            case let .buttonTapped(tap):
                switch tap {
                    
                case .toggleLock:
                    print("toggleLock")
                    
                case .changePin:
                    print("changePin")
                    
                case .showOnMain:
                    print("showOnMain")
                }
            }
        }
        
        return (state, .none)
    }
}

public extension CardGuardianReducer {
    
    typealias State = CardGuardianState
    typealias Event = CardGuardianEvent
    typealias Effect = CardGuardianEffect

    typealias Reduce = (State, Event) -> (State, Effect?)
}
