//
//  SerialLoaderComposer.swift
//
//
//  Created by Igor Malyarov on 15.10.2024.
//

import ForaTools

public final class SerialLoaderComposer<Serial, T, Model>
where Serial: Equatable {
    
    @usableFromInline
    let ephemeral: any Ephemeral
    @usableFromInline
    let persistent: any Persistent
    @usableFromInline
    let remoteLoad: RemoteLoad<[T]>
    @usableFromInline
    let fromModel: (Model) -> T
    @usableFromInline
    let toModel: (T) -> Model
    
    public init(
        ephemeral: any Ephemeral,
        persistent: any Persistent,
        remoteLoad: @escaping RemoteLoad<[T]>,
        fromModel: @escaping (Model) -> T,
        toModel: @escaping (T) -> Model
    ) {
        self.ephemeral = ephemeral
        self.persistent = persistent
        self.remoteLoad = remoteLoad
        self.fromModel = fromModel
        self.toModel = toModel
    }
    
    public typealias Ephemeral = MonolithicStore<[T]>
    public typealias Persistent = MonolithicStore<SerialStamped<Serial, [Model]>>
    
    public typealias RemoteLoadCompletion<Value> = (Result<SerialStamped<Serial, Value>, Error>) -> Void
    public typealias RemoteLoad<Value> = (Serial?, @escaping RemoteLoadCompletion<Value>) -> Void
}

public extension SerialLoaderComposer {
    
    @inlinable
    func compose() -> (load: Load<T>, reload: Load<T>) {
        
        let localLoad = makeLocalLoad()
        let reload = makeReload(localLoad: localLoad)
        let strategy = Strategy(primary: localLoad, fallback: reload)
        
        return (strategy.load(completion:), reload)
    }
}

extension SerialLoaderComposer {
    
    @usableFromInline
    typealias CacheCompletion = () -> Void
    
    @usableFromInline
    typealias Cache<Value> = (SerialStamped<Serial, Value>, @escaping CacheCompletion) -> Void
    
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
    
    @inlinable
    func makeLocalLoad() -> Load<T> {
        
        let strategy = Strategy(
            primary: ephemeral.retrieve,
            fallback: decoratedPersistent
        )
        
        return strategy.load(completion:)
    }
    
    @inlinable
    func decoratedPersistent(
        completion: @escaping LoadCompletion<T>
    ) {
        persistent.retrieve { value in
            
            guard let value else { return completion(nil) }
            
            let list = value.value.map(self.fromModel)
            self.ephemeral.insert(list) { _ in completion(list) }
        }
    }
    
    @inlinable
    func makeReload(
        localLoad: @escaping Load<T>
    ) -> Load<T> {
        
        let caching = SerialStampedCachingDecorator(
            decoratee: remoteLoad,
            cache: cache(toModel: toModel)
        )
        let fallback = SerialFallback(
            primary: caching.decorated,
            secondary: localLoad
        )
        let decoratedRemote = { completion in
            
            self.getSerial { fallback(payload: $0, completion: completion) }
        }
        
        return decoratedRemote
    }
    
    @inlinable
    func getSerial(
        completion: @escaping (Serial?) -> Void
    ) {
        persistent.retrieve { completion($0?.serial) }
    }
}

extension SerialFallback where Payload == Serial? {
    
    @inlinable
    convenience init(
        primary: @escaping Primary,
        secondary: @escaping Secondary
    ) {
        self.init(getSerial: { $0 }, primary: primary, secondary: secondary)
    }
}
