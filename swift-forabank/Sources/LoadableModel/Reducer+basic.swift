//
//  Reducer+basic.swift
//  
//
//  Created by Igor Malyarov on 06.09.2023.
//

public extension LoadableModel.Reducer {
    
    static var basic: Self {
        
        .init { _, action in
            
            switch action {
            case let .loadLocal(result):
                switch result {
                case let .failure(error):
                    return .failure(error)
                    
                case let .success(resource):
                    return .local(resource)
                }
                
            case let .loadRemote(result):
                switch result {
                case let .failure(error):
                    return .failure(error)
                    
                case let .success(resource):
                    return .remote(resource)
                }
            }
        }
    }
}
