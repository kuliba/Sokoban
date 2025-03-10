//
//  SerialLoaderComposer.swift
//
//
//  Created by Igor Malyarov on 15.10.2024.
//

import VortexTools

/// A composer that manages data loading with serial-based caching mechanisms.
/// It integrates in-memory (ephemeral) and on-disk (persistent) storage,
/// handling data synchronisation with remote sources.
public final class SerialLoaderComposer<Serial, T, Model>
where Serial: Equatable {
    
    /// The in-memory store for temporary data caching.
    @usableFromInline
    let ephemeral: any Ephemeral
    /// The on-disk store for long-term data storage.
    @usableFromInline
    let persistent: any Persistent
    /// A closure that defines how to load data from a remote source.
    @usableFromInline
    let remoteLoad: RemoteLoad
    /// A function to convert from `Model` to the domain-specific type `T`.
    @usableFromInline
    let fromModel: (Model) -> T
    /// A function to convert from the domain-specific type `T` to `Model`.
    @usableFromInline
    let toModel: (T) -> Model
    
    /// Initialises a new `SerialLoaderComposer` with the given components.
    /// - Parameters:
    ///   - ephemeral: The in-memory store for caching data.
    ///   - persistent: The on-disk store for persistent storage.
    ///   - remoteLoad: A closure to load data from a remote source.
    ///   - fromModel: A function to convert `Model` instances to type `T`.
    ///   - toModel: A function to convert type `T` instances to `Model`.
    public init(
        ephemeral: any Ephemeral,
        persistent: any Persistent,
        remoteLoad: @escaping RemoteLoad,
        fromModel: @escaping (Model) -> T,
        toModel: @escaping (T) -> Model
    ) {
        self.ephemeral = ephemeral
        self.persistent = persistent
        self.remoteLoad = remoteLoad
        self.fromModel = fromModel
        self.toModel = toModel
    }
    
    /// Typealias representing the in-memory store.
    public typealias Ephemeral = MonolithicStore<[T]>
    /// Typealias representing the on-disk store with serial stamping.
    public typealias Persistent = MonolithicStore<SerialStamped<Serial, [Model]>>
    
    /// Completion handler type for remote loading operations.
    public typealias RemoteLoadCompletion = (Result<SerialStamped<Serial, [T]>, Error>) -> Void
    /// Closure type representing a remote loading operation.
    public typealias RemoteLoad = (Serial?, @escaping RemoteLoadCompletion) -> Void
}

public extension SerialLoaderComposer {
    
    /// Composes and returns the load and reload functions.
    ///
    /// The returned tuple contains:
    /// - `load`: A function that attempts to load data from the local caches (ephemeral and persistent).
    ///   If no valid data is found locally, it automatically falls back to a remote load operation.
    /// - `reload`: A function that explicitly triggers the remote load (with caching) to refresh the data.
    ///   The remote operation is decorated with caching behavior, ensuring that freshly fetched data
    ///   is stored in both caches.
    ///
    /// Use this composition when you want the local load to seamlessly recover by fetching and caching
    /// fresh data from the remote source when necessary, while also having an explicit remote refresh option.
    @inlinable
    func compose() -> (load: Load<[T]?>, reload: Load<[T]?>) {
        
        let reload = makeReload(localLoad: localLoad)
        let strategy = Strategy(primary: localLoad, fallback: reload)
        
        return (strategy.load(completion:), reload)
    }
    
    /// Composes and returns the load and reload functions without a remote fallback on local loads.
    ///
    /// The returned tuple contains:
    /// - `load`: A function that attempts to load data from the local caches (ephemeral and persistent)
    ///   without automatically falling back to a remote fetch if local data is absent.
    /// - `reload`: A function that triggers a remote load which is decorated with caching.
    ///   This ensures that, when explicitly invoked, the remote operation both fetches new data and updates the local caches.
    ///
    /// Use this method when you want to keep local and remote data retrieval operations strictly separate.
    @inlinable
    func composeWithoutFallback() -> (load: Load<[T]?>, reload: Load<[T]?>) {
        
        return (localLoad, makeReload(localLoad: localLoad))
    }
}

extension SerialLoaderComposer {
    
    /// Completion handler type for caching operations.
    @usableFromInline
    typealias CacheCompletion = () -> Void
    
    /// Closure type representing a caching operation.
    @usableFromInline
    typealias Cache<Value> = (SerialStamped<Serial, Value>, @escaping CacheCompletion) -> Void
    
    /// Creates a caching function to store data in both ephemeral and persistent stores.
    /// - Parameter toModel: A function to convert type `T` to `Model`.
    /// - Returns: A caching function that saves data to the stores.
    @inlinable
    func cache(
        toModel: @escaping (T) -> Model
    ) -> Cache<[T]> {
        
        return { [ephemeral, persistent] payload, completion in
            
            ephemeral.insert(payload.value) { _ in
                
                let stamped = SerialStamped(
                    value: payload.value.map(toModel),
                    serial: payload.serial
                )
                persistent.insert(stamped) { _ in completion() }
            }
        }
    }
    
    /// Creates a local load function that first attempts to retrieve data from the ephemeral store,
    /// and falls back to the persistent store if necessary.
    /// - Returns: A load function that retrieves data locally.
    @inlinable
    func localLoad(
        completion: @escaping ([T]?) -> Void
    ) {
        let strategy = Strategy(
            primary: ephemeral.retrieve,
            fallback: decoratedPersistent
        )
        
        return strategy.load { completion($0); _ = strategy }
    }
    
    /// Retrieves data from the persistent store and updates the ephemeral store.
    /// - Parameter completion: Completion handler with the retrieved data or `nil`.
    @inlinable
    func decoratedPersistent(
        completion: @escaping LoadCompletion<[T]?>
    ) {
        persistent.retrieve { value in
            
            guard let value else { return completion(nil) }
            
            let list = value.value.map(self.fromModel)
            self.ephemeral.insert(list) { _ in completion(list) }
        }
    }
    
    /// Creates a reload function that refreshes data from the remote source,
    /// using the serial value for synchronisation.
    /// - Parameter localLoad: The local load function to fall back on.
    /// - Returns: A reload function that updates the data.
    @inlinable
    func makeReload(
        localLoad: @escaping Load<[T]?>
    ) -> Load<[T]?> {
        
        let caching = SerialStampedCachingDecorator(
            decoratee: remoteLoad,
            cache: cache(toModel: toModel)
        )
        let fallback = SerialFallback(
            primary: caching.decorated,
            secondary: localLoad
        )
        let decoratedRemote: Load<[T]?> = { completion in
            
            self.getSerial { serial in
                
                fallback(payload: serial) {
                    
                    completion($0)
                    _ = fallback
                }
            }
        }
        
        return decoratedRemote
    }
    
    /// Retrieves the current serial value from the persistent store.
    /// - Parameter completion: Completion handler with the serial value or `nil`.
    @inlinable
    func getSerial(
        completion: @escaping (Serial?) -> Void
    ) {
        persistent.retrieve { completion($0?.serial) }
    }
}

extension SerialFallback where Payload == Serial? {
    
    /// Convenience initialiser for `SerialFallback` when `Payload` is of type `Serial?`.
    /// - Parameters:
    ///   - primary: The primary function to attempt loading data.
    ///   - secondary: The secondary function to fall back on if the primary fails.
    @inlinable
    convenience init(
        primary: @escaping Primary,
        secondary: @escaping Secondary
    ) {
        self.init(getSerial: { $0 }, primary: primary, secondary: secondary)
    }
}
