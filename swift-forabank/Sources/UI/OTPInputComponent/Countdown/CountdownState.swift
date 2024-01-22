//
//  CountdownState.swift
//
//
//  Created by Igor Malyarov on 19.01.2024.
//

public enum CountdownState: Equatable {
    
    case completed
    case failure(CountdownFailure)
    case running(remaining: Int)
    case starting
}
