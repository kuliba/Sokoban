//
//  LoadableState.swift
//
//
//  Created by Igor Malyarov on 20.03.2025.
//

struct LoadableState<Resource, Failure: Error> {
    
    var resource: Resource?
    var status: LoadStatus
    
    enum LoadStatus {
        
        case loading
        case loadedOK
        case failure(Failure)
    }
}

extension LoadableState: Equatable where Resource: Equatable, Failure: Equatable {}
extension LoadableState.LoadStatus: Equatable where Failure: Equatable {}

extension LoadableState {
    
    var isLoading: Bool {
        
        guard case .loading = status else { return false }
        return true
    }
}

extension LoadableState {
    
    static var idle: Self { .init(resource: nil, status: .loadedOK) }
    
    static var emptyLoading: Self { .init(resource: nil, status: .loading) }
    
    static func loading(
        withResource resource: Resource
    ) -> Self {
        
        return .init(resource: resource, status: .loading)
    }
}
