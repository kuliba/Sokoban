//
//  LoadableState.swift
//
//
//  Created by Igor Malyarov on 20.03.2025.
//

struct LoadableState<Resource, Failure: Error> {
    
    var resource: Resource?
    var result: Result<Success, Failure>?
    
    struct Success: Equatable {}
}

extension LoadableState: Equatable where Resource: Equatable, Failure: Equatable {}

extension LoadableState {
    
    var isLoading: Bool { result == nil }
}
