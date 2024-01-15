//
//  Reducer.swift
//  ForaBank
//
//  Created by Igor Malyarov on 10.01.2024.
//

protocol Reducer<State, Event> {
    
    associatedtype State
    associatedtype Event
    
    func reduce(
        _ state: State,
        _ event: Event,
        _ completion: @escaping (State) -> Void
    )
}
