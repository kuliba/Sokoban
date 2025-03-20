//
//  LoadableEvent.swift
//
//
//  Created by Igor Malyarov on 20.03.2025.
//

enum LoadableEvent<Resource> {
    
    case load
    case loaded(Resource)
}

extension LoadableEvent: Equatable where Resource: Equatable {}
