//
//  LocalAgentLoader.swift
//  ForaBank
//
//  Created by Igor Malyarov on 09.09.2024.
//

struct LocalAgentLoader<LoadPayload, Value> {
    
    let load: (LoadPayload, @escaping (Value?) -> Void) -> Void
    let save: (Value, @escaping (Result<Void, Error>) -> Void) -> Void
}
