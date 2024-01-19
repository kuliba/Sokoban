//
//  CountdownEvent.swift
//
//
//  Created by Igor Malyarov on 18.01.2024.
//

public enum CountdownEvent: Equatable {
    
    case failure(CountdownFailure)
    case prepare
    case start
    case tick
}
