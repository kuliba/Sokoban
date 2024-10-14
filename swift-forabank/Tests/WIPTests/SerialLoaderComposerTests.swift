//
//  SerialLoaderComposerTests.swift
//
//
//  Created by Igor Malyarov on 14.10.2024.
//

import EphemeralStores
import ForaTools
import GenericLoader

protocol MonolithicStore<Value> {
    
    associatedtype Value
    
    func insert(_: Value, _: @escaping (Result<Void, Error>) -> Void)
    func retrieve(_: @escaping (Value?) -> Void)
    func delete()
}

typealias LoadCompletion<T> = ([T]?) -> Void
typealias Load<T> = (@escaping LoadCompletion<T>) -> Void

final class SerialLoaderComposer<Serial, T, Model>
where Serial: Equatable {
    
    private let ephemeral: any Ephemeral
    private let persistent: any Persistent
    private let remoteLoad: RemoteLoad<[T]>
    private let fromModel: (Model) -> T
    private let toModel: (T) -> Model
    
    init(
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
    
    typealias Ephemeral = MonolithicStore<[T]>
    typealias Persistent = MonolithicStore<SerialStamped<Serial, Model>>
    
    typealias RemoteLoadCompletion<Value> = (Result<ForaTools.SerialStamped<Serial, Value>, Error>) -> Void
    typealias RemoteLoad<Value> = (Serial?, @escaping RemoteLoadCompletion<Value>) -> Void
}

extension SerialLoaderComposer {
    
    @inlinable
    func compose() -> (load: Load<T>, reload: Load<T>) {
        
        let localLoad = makeLocalLoad()
        let reload = makeReload(localLoad: localLoad)
        let strategy = Strategy(primary: localLoad, fallback: reload)
        
        return (strategy.load(completion:), reload)
    }
}

extension SerialLoaderComposer {
    
    typealias CacheCompletion = () -> Void
    typealias Cache<Value> = (ForaTools.SerialStamped<Serial, Value>, @escaping CacheCompletion) -> Void
    
    @inlinable
    func cache(
        toModel: @escaping (T) -> Model
    ) -> Cache<[T]> {
        
        return { [ephemeral, persistent] payload, completion in
            
            ephemeral.insert(payload.value) { _ in
                
                let stamped = SerialStamped(
                    list: payload.value.map(toModel),
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
            
            let list = value.list.map(self.fromModel)
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
    
    convenience init(
        primary: @escaping Primary,
        secondary: @escaping Secondary
    ) {
        self.init(getSerial: { $0 }, primary: primary, secondary: secondary)
    }
}

import XCTest

//final class SerialLoaderComposerTests: XCTestCase {
//
//    // MARK: - Helpers
//
//    private typealias SUT = SerialLoaderComposer
//
//    private func makeSUT(
//        file: StaticString = #file,
//        line: UInt = #line
//    ) -> SUT {
//
//        let sut = SUT()
//
//        trackForMemoryLeaks(sut, file: file, line: line)
//
//        return sut
//    }
//
//}
