//
//  SerialLoaderComposer+ext.swift
//  ForaBank
//
//  Created by Igor Malyarov on 15.10.2024.
//

import EphemeralStores
import ForaTools
import SerialComponents

extension SerialComponents.SerialLoaderComposer
where Serial == String,
      Model: Codable {
    
    convenience init(
        localAgent: any LocalAgentProtocol,
        remoteLoad: @escaping RemoteLoad<[T]>,
        fromModel: @escaping (Model) -> T,
        toModel: @escaping (T) -> Model
    ) {
        self.init(
            ephemeral: EphemeralStores.InMemoryStore<[T]>(),
            persistent: LocalAgentWrapper(localAgent: localAgent),
            remoteLoad: remoteLoad,
            fromModel: fromModel,
            toModel: toModel
        )
    }
}

extension EphemeralStores.InMemoryStore: MonolithicStore {
    
    nonisolated public func insert(
        _ value: Value,
        _ completion : @escaping InsertCompletion
    ) {
        Task {
            
            await self.insert(value)
            completion(.success(()))
        }
    }
    
    nonisolated public func retrieve(
        _ completion : @escaping RetrieveCompletion
    ) {
        Task {
            
            let cache = await self.retrieve()
            completion(cache)
        }
    }
}
