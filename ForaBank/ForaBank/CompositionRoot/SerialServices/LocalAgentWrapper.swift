//
//  LocalAgentWrapper.swift
//  ForaBank
//
//  Created by Igor Malyarov on 15.10.2024.
//

import ForaTools
import SerialComponents

actor LocalAgentWrapper<Model: Codable> {
    
    private let localAgent: LocalAgentProtocol
    
    init(localAgent: LocalAgentProtocol) {
        
        self.localAgent = localAgent
    }
    
    func insert(
        _ stamped: SerialStamped<String, Model>
    ) throws {
        
        try localAgent.store(stamped.value, serial: stamped.serial)
    }
    
    func retrieve() -> SerialStamped<String, Model>? {
        
        let value = localAgent.load(type: Model.self)
        let serial = localAgent.serial(for: Model.self)
        
        guard let value, let serial else { return nil }
        
        return .init(value: value, serial: serial)
    }
}

extension LocalAgentWrapper: MonolithicStore {
    
    typealias Value = SerialStamped<String, Model>
    
    nonisolated func insert(
        _ stamped: SerialStamped<String, Model>,
        _ completion: @escaping InsertCompletion
    ) {
        Task {
            do {
                try await insert(stamped)
                completion(.success(()))
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    nonisolated func retrieve(
        _ completion: @escaping RetrieveCompletion
    ) {
        Task {
            
            let value = await retrieve()
            completion(value)
        }
    }
}
