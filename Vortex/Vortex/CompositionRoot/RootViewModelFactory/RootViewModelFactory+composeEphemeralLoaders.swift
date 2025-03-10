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
    
    typealias SerialLoaderComposer<T> = SerialComponents.SerialLoaderComposer<String, T, T>
    
    @inlinable
    func composeEphemeralLoaders<T>(
        remoteLoad: @escaping SerialLoaderComposer<T>.RemoteLoad
    ) -> (load: Load<[T]?>, reload: Load<[T]?>) {
        
        let composer = SerialLoaderComposer(
            ephemeral: EphemeralStores.InMemoryStore<[T]>(),
            persistent: NullMonolithicStore<SerialComponents.SerialStamped<String, [T]>>(),
            remoteLoad: remoteLoad,
            fromModel: { $0 },
            toModel: { $0 }
        )
        
        return composer.compose()
    }
}
