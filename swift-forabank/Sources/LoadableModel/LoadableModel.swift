//
//  LoadableModel.swift
//  
//
//  Created by Igor Malyarov on 06.09.2023.
//

import Foundation

/// Observe `state` updates initiated from different async sources (local and remote loaders). Uses reducer to encapsulate state update logic depending on the current state and load results.
/// - Note: Specific naming “local” and “remote” is used to provide and simplify context. More abstract naming could be beneficial, but in fact the real logic is encapsulated in the reducer.
public final class LoadableModel<Resource, Failure>
where Failure: Error {
    
    private var state: State
    
    public typealias Observe = (State) -> Void
    public typealias LoadResult = Result<Resource, Failure>
    public typealias Completion = (LoadResult) -> Void
    public typealias Load = (@escaping Completion) -> Void
    
    private let observe: Observe
    private let localLoad: Load
    private let remoteLoad: Load
    private let reduce: Reducer.Reduce
    private let lock = NSLock()
    
    public init(
        initialState: State,
        localLoad: @escaping Load,
        remoteLoad: @escaping Load,
        reduce: @escaping Reducer.Reduce,
        observe: @escaping Observe
    ) {
        self.state = initialState
        self.localLoad = localLoad
        self.remoteLoad = remoteLoad
        self.reduce = reduce
        self.observe = observe
    }
}

extension LoadableModel {
    
    public func load() {
        
        localLoad { [weak self] result in
            
            self?.reduce(action: .loadLocal(result))
        }
        
        remoteLoad { [weak self] result in
            
            self?.reduce(action: .loadRemote(result))
        }
    }
    
    private func reduce(action: Action) {
        
        lock.lock()
        
        state = reduce(state, action)
        observe(state)
        
        lock.unlock()
    }
}

// MARK: - Types

extension LoadableModel {
    
    public enum State {
        
        case placeholder
        case local(Resource)
        case remote(Resource)
        case failure(Failure)
        case failure2(Resource, Failure)
    }
    
    public enum Action {
        
        case loadLocal(Result<Resource, Failure>)
        case loadRemote(Swift.Result<Resource, Failure>)
    }
    
    public struct Reducer {
        
        public typealias Reduce = (State, Action) -> State
        
        public let reduce: Reduce
        
        public init(reduce: @escaping Reduce) {
            
            self.reduce = reduce
        }
    }
}

extension LoadableModel.State: Equatable where Resource: Equatable, Failure: Equatable {}
