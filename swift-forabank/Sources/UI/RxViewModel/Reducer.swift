//
//  Reducer.swift
//
//
//  Created by Igor Malyarov on 20.01.2024.
//

public protocol Reducer<State, Event, Effect> {
    
    associatedtype State: Equatable
    associatedtype Event: Equatable
    associatedtype Effect: Equatable
    
    func reduce(_ state: State,_ event: Event) -> (State, Effect?)
}
