//
//  SerialLoaderComposerTests.swift
//
//
//  Created by Igor Malyarov on 14.10.2024.
//

import EphemeralStores
import ForaTools
import GenericLoader

// protocol MonolithicStampedStore<T> {
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
    
    init(
        ephemeral: any Ephemeral,
        persistent: any Persistent
    ) {
        self.ephemeral = ephemeral
        self.persistent = persistent
    }
    
    typealias Ephemeral = MonolithicStore<[T]>
    typealias Persistent = MonolithicStore<SerialStamped<Serial, Model>>
}

extension SerialLoaderComposer {
    
    typealias RemoteLoadCompletion<Value>  = (Result<ForaTools.SerialStamped<Serial, Value>, Error>) -> Void
    typealias RemoteLoad<Value> = (Serial?, @escaping RemoteLoadCompletion<Value>) -> Void
    
    typealias CacheCompletion = () -> Void
    typealias Cache<Value> = (ForaTools.SerialStamped<Serial, Value>, @escaping CacheCompletion) -> Void
    
    @inlinable
    func compose(
        remoteLoad: @escaping RemoteLoad<[T]>,
        fromModel: @escaping (Model) -> T,
        toModel: @escaping (T) -> Model
    ) -> (load: Load<T>, reload: Load<T>) {
        
        let localLoad = makeLocalLoad(fromModel: fromModel)
        
        let reload = makeReload(
            localLoad: localLoad,
            getSerial: getSerial,
            remoteLoad: remoteLoad,
            cache: cache(toModel: toModel)
        )
        let strategy = Strategy(primary: localLoad, fallback: reload)
        
        return (strategy.load(completion:), reload)
    }
}

extension SerialLoaderComposer {
    
    @inlinable
    func cache(
        toModel: @escaping (T) -> Model
    ) -> (ForaTools.SerialStamped<Serial, [T]>, @escaping () -> Void) -> Void {
        
        return { [ephemeral, persistent] payload, completion in
            
            ephemeral.insert(payload.value) { [persistent] _ in
                
                let stamped = SerialStamped(
                    list: payload.value.map(toModel),
                    serial: payload.serial
                )
                persistent.insert(stamped) { _ in completion() }
            }
        }
    }
    
    @inlinable
    func getSerial(
        completion: @escaping (Serial?) -> Void
    ) {
        persistent.retrieve { completion($0?.serial) }
    }
    
    @inlinable
    func makeLocalLoad(
        fromModel: @escaping (Model) -> T
    ) -> Load<T> {
        
        let strategy = Strategy(
            primary: ephemeral.retrieve,
            fallback: decoratedPersistent(fromModel: fromModel)
        )
        
        return strategy.load(completion:)
    }
    
    @inlinable
    func decoratedPersistent(
        fromModel: @escaping (Model) -> T
    ) -> Load<T> {
        
        return { [ephemeral, persistent] completion in
            
            persistent.retrieve { value in
                
                switch value {
                case .none:
                    completion(nil)
                    
                case let .some(stamped):
                    let value = stamped.list.map(fromModel)
                    ephemeral.insert(value) { _ in completion(value) }
                }
            }
        }
    }
    
    @inlinable
    func makeReload(
        localLoad: @escaping Load<T>,
        getSerial: @escaping (@escaping (Serial?) -> Void) -> Void,
        remoteLoad: @escaping RemoteLoad<[T]>,
        cache: @escaping Cache<[T]>
    ) -> Load<T> {
        
        let caching = SerialStampedCachingDecorator(
            decoratee: remoteLoad,
            cache: cache
        )
        let fallback = SerialFallback(
            primary: caching.decorated,
            secondary: localLoad
        )
        let decoratedRemote = { completion in
            
            getSerial { fallback(payload: $0, completion: completion) }
        }
        let strategy = Strategy(primary: decoratedRemote, fallback: localLoad)
        
        return strategy.load(completion:)
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
