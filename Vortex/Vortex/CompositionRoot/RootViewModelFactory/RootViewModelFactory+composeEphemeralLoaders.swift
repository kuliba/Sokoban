//
//  RootViewModelFactory+composeEphemeralLoaders.swift
//  Vortex
//
//  Created by Igor Malyarov on 09.03.2025.
//

import EphemeralStores
import RemoteServices
import SerialComponents

extension RootViewModelFactory {
    
    @inlinable
    func composeEphemeralLoaders<T, Model: Codable>(
        remoteLoad: @escaping SerialLoaderComposer<T, Model>.RemoteLoad,
        fromModel: @escaping (Model) -> T,
        toModel: @escaping (T) -> Model
    ) -> (load: Load<[T]>, reload: Load<[T]>) {
        
        return composeLoaders(
            localAgent: NullLocalAgent(),
            remoteLoad: remoteLoad,
            fromModel: fromModel,
            toModel: toModel
        )
    }
}
