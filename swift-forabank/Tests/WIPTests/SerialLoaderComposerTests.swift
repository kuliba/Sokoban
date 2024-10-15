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
    
    typealias InsertCompletion = (Result<Void, Error>) -> Void
    typealias RetrieveCompletion = (Value?) -> Void
    
    func insert(_: Value, _: @escaping InsertCompletion)
    func retrieve(_: @escaping RetrieveCompletion)
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

final class SerialLoaderComposerTests: XCTestCase {
    
    // MARK: - init
    
    func test_init_shouldNotCallCollaborators() {
        
        let (sut, ephemeral, persistent, remoteLoad) = makeSUT()
        
        XCTAssertEqual(ephemeral.insertMessages.count, 0)
        XCTAssertEqual(ephemeral.retrieveMessages.count, 0)
        XCTAssertEqual(persistent.insertMessages.count, 0)
        XCTAssertEqual(persistent.retrieveMessages.count, 0)
        XCTAssertEqual(remoteLoad.callCount, 0)
        XCTAssertNotNil(sut)
    }

    // MARK: - load

    // MARK: - reload
    
    // MARK: - Helpers
    
    private typealias Serial = String
    private typealias SUT = SerialLoaderComposer<Serial, Value, Model>
    private typealias RemoteLoadSpy = Spy<Serial?, Result<ForaTools.SerialStamped<Serial, [Value]>, Error>>
    private typealias EphemeralSpy = MonolithicStoreSpy<[Value]>
    private typealias PersistentSpy = MonolithicStoreSpy<SerialStamped<Serial, Model>>
    
    private func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        ephemeralSpy: EphemeralSpy,
        persistentSpy: PersistentSpy,
        remoteLoadSpy: RemoteLoadSpy
    ) {
        let ephemeralSpy = EphemeralSpy()
        let persistentSpy = PersistentSpy()
        let remoteLoadSpy = RemoteLoadSpy()
        let sut = SUT(
            ephemeral: ephemeralSpy,
            persistent: persistentSpy,
            remoteLoad: remoteLoadSpy.process(_:completion:),
            fromModel: { .init(value: $0.value) },
            toModel: { .init(value: $0.value) }
        )
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(ephemeralSpy, file: file, line: line)
        trackForMemoryLeaks(persistentSpy, file: file, line: line)
        trackForMemoryLeaks(remoteLoadSpy, file: file, line: line)
        
        return (sut, ephemeralSpy, persistentSpy, remoteLoadSpy)
    }
    
    private struct Value: Equatable {
        
        let value: String
    }
    
    private func makeValue(
        _ value: String = anyMessage()
    ) -> Value {
        
        return .init(value: value)
    }
    
    private struct Model: Equatable {
        
        let value: String
    }
    
    private func makeModel(
        _ value: String = anyMessage()
    ) -> Model {
        
        return .init(value: value)
    }
}

final class MonolithicStoreSpy<Value>: MonolithicStore {
    
    private(set) var insertMessages = [InsertMessage]()
    private(set) var retrieveMessages = [RetrieveCompletion]()
    
    func insert(
        _ value: Value,
        _ completion: @escaping InsertCompletion
    ) {
        insertMessages.append((value, completion))
    }
    
    func retrieve(
        _ completion: @escaping (Value?) -> Void // RetrieveCompletion
    ) {
        retrieveMessages.append(completion)
    }
    
    func completeInsert(
        with result: Result<Void, Error>,
        at index: Int = 0
    ) {
        insertMessages[index].completion(result)
    }
    
    func completeInsertWithError(
        _ error: Error = anyError(),
        at index: Int = 0
    ) {
        insertMessages[index].completion(.failure(error))
    }
    
    func completeInsertSuccessfully(
        at index: Int = 0
    ) {
        insertMessages[index].completion(.success(()))
    }
    
    func completeRetrieve(
        with value: Value?,
        at index: Int = 0
    ) {
        retrieveMessages[index](value)
    }
    
    typealias InsertMessage = (value: Value, completion: InsertCompletion)
}
