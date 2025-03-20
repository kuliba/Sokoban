//
//  LoadableState.swift
//
//
//  Created by Igor Malyarov on 20.03.2025.
//

/// Represents the state of a loadable resource.
public struct LoadableState<Resource, Failure: Error> {
    
    /// The loaded resource, if available.
    public var resource: Resource?
    
    /// The current load status of the resource.
    public var status: LoadStatus
    
    /// Initializes a new loadable state.
    /// - Parameters:
    ///   - resource: The loaded resource, if available.
    ///   - status: The current load status.
    public init(
        resource: Resource? = nil,
        status: LoadStatus
    ) {
        self.resource = resource
        self.status = status
    }
    
    /// Represents the possible load states.
    public enum LoadStatus {
        
        /// The resource is actively loading.
        case loading
        
        /// The resource has been successfully loaded.
        case loadedOK
        
        /// The resource failed to load.
        case failure(Failure)
    }
}

extension LoadableState: Equatable where Resource: Equatable, Failure: Equatable {}
extension LoadableState.LoadStatus: Equatable where Failure: Equatable {}

public extension LoadableState {
    
    /// Indicates whether the state is currently in a loading phase.
    var isLoading: Bool {
        guard case .loading = status else { return false }
        return true
    }
    
    /// A predefined idle state where no resource is loaded, and status is `loadedOK`.
    static var idle: Self { .init(resource: nil, status: .loadedOK) }
    
    /// A predefined state representing an empty resource in a loading phase.
    static var emptyLoading: Self { .init(resource: nil, status: .loading) }
    
    /// Creates a loading state with a given resource.
    /// - Parameter resource: The resource to associate with the loading state.
    /// - Returns: A new instance of `LoadableState` in a loading phase.
    static func loading(
        withResource resource: Resource
    ) -> Self {
        return .init(resource: resource, status: .loading)
    }
}
