//
//  Reducer.swift
//  
//
//  Created by Andryusina Nataly on 13.06.2023.
//

import Foundation

protocol Reducer<State, Action> {
    
    associatedtype State
    associatedtype Action
    associatedtype Options
    
    var options: Options { get }

    func reduce(
        _ state: State,
        action: Action) -> State
}
