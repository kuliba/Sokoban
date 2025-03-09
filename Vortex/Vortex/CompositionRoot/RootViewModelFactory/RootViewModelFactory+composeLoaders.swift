//
//  RootViewModelFactory+composeLoaders.swift
//  Vortex
//
//  Created by Igor Malyarov on 19.10.2024.
//

import RemoteServices
import SerialComponents

extension RootViewModelFactory {
    
    typealias SerialLoaderComposer<T, Model> = SerialComponents.SerialLoaderComposer<String, T, Model> where Model: Codable
    
    @inlinable
    func composeLoaders<T, Model>(
        localAgent: (any LocalAgentProtocol)? = nil,
        remoteLoad: @escaping SerialLoaderComposer<T, Model>.RemoteLoad,
        fromModel: @escaping (Model) -> T,
        toModel: @escaping (T) -> Model
    ) -> (load: Load<[T]>, reload: Load<[T]>) {
        
        let composer = SerialLoaderComposer(
            localAgent: localAgent ?? model.localAgent,
            remoteLoad: remoteLoad,
            fromModel: fromModel,
            toModel: toModel
        )
        
        return composer.compose()
    }
}
