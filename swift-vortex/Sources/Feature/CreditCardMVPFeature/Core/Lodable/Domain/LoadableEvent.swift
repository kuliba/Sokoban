//
//  LoadableEvent.swift
//
//
//  Created by Igor Malyarov on 20.03.2025.
//

public enum LoadableEvent<Resource, Failure: Error> {
    
    case load
    case loaded(Result<Resource, Failure>)
}

extension LoadableEvent: Equatable where Resource: Equatable, Failure: Equatable {}
