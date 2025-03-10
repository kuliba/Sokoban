//
//  RootViewModelFactory+composeLoaders.swift
//  Vortex
//
//  Created by Igor Malyarov on 19.10.2024.
//

import RemoteServices
import SerialComponents

extension RootViewModelFactory {
    
    /// Type alias for a serial loader composer that works with Codable models.
    ///
    /// This alias represents a `SerialLoaderComposer` configured with a `String` serial,
    /// and requires that the model type conforms to `Codable`. It is used to compose
    /// load and reload functions that integrate local and remote data fetching with caching.
    typealias CodableSerialLoaderComposer<T, Model> = SerialComponents.SerialLoaderComposer<String, T, Model> where Model: Codable
    
    /// Composes and returns load and reload functions using a `CodableSerialLoaderComposer`.
    ///
    /// This helper function creates a `CodableSerialLoaderComposer` configured with a provided
    /// or default local agent, a remote load function, and conversion functions (`fromModel` and `toModel`).
    ///
    /// The returned tuple contains:
    /// - `load`: A function that attempts to retrieve data from local caches managed by the local agent.
    ///   If local data is not available, it automatically falls back to a remote load operation that is decorated with caching.
    /// - `reload`: A function that explicitly triggers the decorated remote load to refresh the data,
    ///   ensuring that any fetched data is stored in both the in-memory and on-disk caches.
    ///
    /// - Parameters:
    ///   - localAgent: An optional local agent to manage local caching. If not provided, the default agent from `model.localAgent` is used.
    ///   - remoteLoad: A closure that loads data from a remote source.
    ///   - fromModel: A function to convert a model instance (`Model`) to the domain type (`T`).
    ///   - toModel: A function to convert a domain type instance (`T`) to a model (`Model`).
    /// - Returns: A tuple containing the `load` and `reload` functions.
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
    
    /// Composes and returns load and reload functions using a `CodableSerialLoaderComposer`
    /// without a remote fallback on local loads.
    ///
    /// This helper function creates a `CodableSerialLoaderComposer` configured with a provided
    /// or default local agent, a remote load function, and conversion functions (`fromModel` and `toModel`).
    ///
    /// The returned tuple contains:
    /// - `load`: A function that strictly attempts to retrieve data from local caches managed by the local agent,
    ///   without automatically falling back to a remote load if local data is absent.
    /// - `reload`: A function that explicitly triggers the decorated remote load to refresh the data
    ///   and update the local caches.
    ///
    /// - Parameters:
    ///   - localAgent: An optional local agent for managing local caching. If not provided, the default agent from `model.localAgent` is used.
    ///   - remoteLoad: A closure that loads data from a remote source.
    ///   - fromModel: A function to convert a model instance (`Model`) to the domain type (`T`).
    ///   - toModel: A function to convert a domain type instance (`T`) to a model (`Model`).
    /// - Returns: A tuple containing the `load` and `reload` functions.
    @inlinable
    func composeLoadersWithoutFallback<T, Model>(
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
        
        return composer.composeWithoutFallback()
    }
}
