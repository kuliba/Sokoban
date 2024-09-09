//
//  LocalAgentLoader.swift
//  ForaBank
//
//  Created by Igor Malyarov on 09.09.2024.
//

struct LocalAgentLoader<LoadPayload, Value> {
    
    let load: (LoadPayload, @escaping (StoredData?) -> Void) -> Void
    let save: (StoredData, @escaping (Result<Void, Error>) -> Void) -> Void
}

extension LocalAgentLoader {
    
    typealias StoredData = LocalAgentStoredData<Value>
}
