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
    
    /// Type alias for a serial loader composer that operates on the same type for both domain and model.
    ///
    /// This alias represents a `SerialLoaderComposer` configured with a `String` serial and
    /// uses the same type for both the domain (`T`) and the model. This setup means that no
    /// conversion between types is necessary.
    typealias SerialLoaderComposer<T> = SerialComponents.SerialLoaderComposer<String, T, T>
    
    /// Composes and returns load and reload functions for ephemeral-only storage.
    ///
    /// This helper function creates a `SerialLoaderComposer` using an in-memory store for the ephemeral cache
    /// and a null persistent store (i.e. no on-disk caching). This configuration is useful when you only need transient
    /// caching during the application's lifetime.
    ///
    /// The returned tuple contains:
    /// - `load`: A function that attempts to load data from the in-memory store.
    ///   If local data is absent, it falls back to a decorated remote load that caches the data in the in-memory store.
    /// - `reload`: A function that explicitly triggers the decorated remote load to refresh the data.
    ///
    /// - Parameter remoteLoad: A closure that loads data from a remote source.
    /// - Returns: A tuple containing the `load` and `reload` functions.
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
    
    /// Composes and returns load and reload functions for ephemeral-only storage without a remote fallback.
    ///
    /// This helper function creates a `SerialLoaderComposer` using an in-memory store for the ephemeral cache
    /// and a null persistent store (i.e. no on-disk caching). This configuration is used when you want the local load
    /// to rely solely on in-memory data without automatically fetching from a remote source.
    ///
    /// The returned tuple contains:
    /// - `load`: A function that strictly loads data from the in-memory store, without falling back to a remote fetch.
    /// - `reload`: A function that explicitly triggers the decorated remote load to refresh the data and update the in-memory store.
    ///
    /// - Parameter remoteLoad: A closure that loads data from a remote source.
    /// - Returns: A tuple containing the `load` and `reload` functions.
    @inlinable
    func composeEphemeralLoadersWithoutFallback<T>(
        remoteLoad: @escaping SerialLoaderComposer<T>.RemoteLoad
    ) -> (load: Load<[T]?>, reload: Load<[T]?>) {
        
        let composer = SerialLoaderComposer(
            ephemeral: EphemeralStores.InMemoryStore<[T]>(),
            persistent: NullMonolithicStore<SerialComponents.SerialStamped<String, [T]>>(),
            remoteLoad: remoteLoad,
            fromModel: { $0 },
            toModel: { $0 }
        )
        
        return composer.composeWithoutFallback()
    }
}
