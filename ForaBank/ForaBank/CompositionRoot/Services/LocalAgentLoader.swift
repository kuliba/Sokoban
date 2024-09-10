//
//  LocalAgentLoader.swift
//  ForaBank
//
//  Created by Igor Malyarov on 09.09.2024.
//

struct LocalAgentLoader<LoadPayload, Value> {
    
    let load: (LoadPayload, @escaping (Stamped?) -> Void) -> Void
    let save: (Stamped, @escaping (Result<Void, Error>) -> Void) -> Void
}

extension LocalAgentLoader {
    
    typealias Stamped = SerialStamped<Value>
}
