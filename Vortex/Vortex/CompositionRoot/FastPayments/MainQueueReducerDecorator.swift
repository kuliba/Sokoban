//
//  MainQueueReducerDecorator.swift
//  Vortex
//
//  Created by Igor Malyarov on 10.01.2024.
//

import Foundation

final class MainQueueReducerDecorator<State, Event> {
    
    private let reducer: any Reducer<State, Event>
    
    init(reducer: any Reducer<State, Event>) {
        
        self.reducer = reducer
    }
}

extension MainQueueReducerDecorator: Reducer {
    
    func reduce(
        _ state: State,
        _ event: Event,
        _ completion: @escaping (State) -> Void
    ) {
        reducer.reduce(state, event) { state in
            
            DispatchQueue.main.async {
                
                completion(state)
            }
        }
    }
}
