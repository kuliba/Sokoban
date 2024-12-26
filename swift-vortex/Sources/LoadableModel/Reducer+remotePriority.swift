//
//  Reducer+remotePriority.swift
//  
//
//  Created by Igor Malyarov on 06.09.2023.
//

public extension LoadableModel.Reducer {
    
    static var remotePriority: Self {
        
        .init { state, action in
            
            switch (state, action) {
                
                // MARK: - load failures
                
            case (.placeholder, .loadLocal(.failure)):
                return .placeholder
                
            case let (.placeholder, .loadRemote(.failure(error))),
                let (.failure, .loadRemote(.failure(error))):
                return .failure(error)
                
            case let (.local(resource), .loadRemote(.failure(error))),
                let (.remote(resource), .loadRemote(.failure(error))),
                let (.failure2(resource, _), .loadRemote(.failure(error))):
                return .failure2(resource, error)
                
                // MARK: - load successes
                
            case let (.placeholder, .loadLocal(.success(resource))),
                let (.local, .loadLocal(.success(resource))):
                return .local(resource)
                
            case let (_, .loadRemote(.success(resource))):
                return .remote(resource)
                
                // MARK: - no changes
                
            default:
                return state
            }
        }
    }
}

