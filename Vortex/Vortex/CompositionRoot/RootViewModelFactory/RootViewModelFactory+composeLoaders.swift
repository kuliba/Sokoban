//
//  RootViewModelFactory+composeLoaders.swift
//  Vortex
//
//  Created by Igor Malyarov on 19.10.2024.
//

import RemoteServices
import SerialComponents

extension RootViewModelFactory {
    
    typealias CodableSerialLoaderComposer<T, Model> = SerialComponents.SerialLoaderComposer<String, T, Model> where Model: Codable
    
    @inlinable
    func composeLoaders<T, Model>(
        localAgent: (any LocalAgentProtocol)? = nil,
        remoteLoad: @escaping CodableSerialLoaderComposer<T, Model>.RemoteLoad,
        fromModel: @escaping (Model) -> T,
        toModel: @escaping (T) -> Model
    ) -> (load: Load<[T]?>, reload: Load<[T]?>) {
        
        let composer = CodableSerialLoaderComposer(
            localAgent: localAgent ?? model.localAgent,
            remoteLoad: remoteLoad,
            fromModel: fromModel,
            toModel: toModel
        )
        
        return composer.compose()
    }
}
