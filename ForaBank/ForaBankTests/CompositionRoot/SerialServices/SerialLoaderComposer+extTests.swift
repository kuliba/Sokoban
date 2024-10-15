//
//  SerialLoaderComposer+extTests.swift
//  ForaBankTests
//
//  Created by Igor Malyarov on 15.10.2024.
//

import CombineSchedulers
import EphemeralStores
import ForaTools
import SerialComponents

extension SerialComponents.SerialLoaderComposer
where Serial == String,
      Model: Codable {
    
    convenience init(
        localAgent: any LocalAgentProtocol,
        remoteLoad: @escaping RemoteLoad<[T]>,
        fromModel: @escaping (Model) -> T,
        toModel: @escaping (T) -> Model
    ) {
        self.init(
            ephemeral: EphemeralStores.InMemoryStore<[T]>(),
            persistent: LocalAgentWrapper(localAgent: localAgent),
            remoteLoad: remoteLoad,
            fromModel: fromModel,
            toModel: toModel
        )
    }
}

extension EphemeralStores.InMemoryStore: MonolithicStore {
    
    nonisolated public func insert(
        _ value: Value,
        _ completion : @escaping InsertCompletion
    ) {
        Task {
            
            await self.insert(value)
            completion(.success(()))
        }
    }
    
    nonisolated public func retrieve(
        _ completion : @escaping RetrieveCompletion
    ) {
        Task {
            
            let cache = await self.retrieve()
            completion(cache)
        }
    }
}

actor LocalAgentWrapper<Value: Codable> {
    
    private let localAgent: LocalAgentProtocol
    
    init(localAgent: LocalAgentProtocol) {
        
        self.localAgent = localAgent
    }
    
    func insert(
        _ stamped: SerialStamped<String, Value>
    ) throws {
        
        try localAgent.store(stamped.value, serial: stamped.serial)
    }
    
    func retrieve() -> SerialStamped<String, Value>? {
        
        let value = localAgent.load(type: Value.self)
        let serial = localAgent.serial(for: Value.self)
        
        guard let value, let serial else { return nil }
        
        return .init(value: value, serial: serial)
    }
}

extension LocalAgentWrapper: MonolithicStore {
    
    nonisolated func insert(
        _ stamped: SerialStamped<String, Value>,
        _ completion: @escaping InsertCompletion
    ) {
        Task {
            do {
                try await insert(stamped)
                completion(.success(()))
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    nonisolated func retrieve(
        _ completion: @escaping RetrieveCompletion
    ) {
        Task {
            
            let value = await retrieve()
            completion(value)
        }
    }
}

import ForaTools
@testable import ForaBank
import SerialComponents
import XCTest

final class SerialLoaderComposer_extTests: XCTestCase {
    
    func test_init_shouldNotCallCollaborators() {
        
        let (sut, localAgent, remoteLoad) = makeSUT()
        
        XCTAssertEqual(localAgent.loadCallCount, 0)
        XCTAssertEqual(localAgent.storeCallCount, 0)
        XCTAssertEqual(remoteLoad.callCount, 0)
        XCTAssertNotNil(sut)
    }
    
    func test_load_shouldCallRemote() {
        
        let (sut, _, remoteLoad) = makeSUT()
        
        expect(sut.compose().load) {
            
            remoteLoad.complete(with: .success(.init(value: [], serial: anyMessage())))
        }
    }
    
    func test_load_shouldNotCallRemoteOnSecondLoad() {
        
        let (sut, _, remoteLoad) = makeSUT()
        
        expect(sut.compose().load, "wait for first load completion") {
            
            remoteLoad.complete(with: .success(.init(value: [], serial: anyMessage())))
        }
        
        expect(sut.compose().load, "wait for second load completion") {}
        
        XCTAssertEqual(remoteLoad.callCount, 1)
    }
    
    func test_reload_shouldCallRemote() {
        
        let (sut, _, remoteLoad) = makeSUT()
        
        expect(sut.compose().reload) {
            
            remoteLoad.complete(with: .success(.init(value: [], serial: anyMessage())))
        }
    }
    
    // MARK: - Helpers
    
    private typealias Serial = String
    private typealias SUT = SerialComponents.SerialLoaderComposer<Serial, Value, Model>
    private typealias LocalAgentSpy = ForaBankTests.LocalAgentSpy<SerialStamped<Serial, [Model]>>
    private typealias RemoteLoadSpy = Spy<Serial?, SerialStamped<Serial, [Value]>, Error>
    
    private func makeSUT(
        persisted loadStub: SerialStamped<Serial, [Model]>? = nil,
        storeStub: Result<Void, any Error> = .success(()),
        serialStub: String? = nil,
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        localAgentSpy: LocalAgentSpy,
        remoteLoadSpy: RemoteLoadSpy
    ) {
        let localAgentSpy = LocalAgentSpy(
            loadStub: loadStub,
            storeStub: storeStub,
            serialStub: serialStub
        )
        let remoteLoadSpy = RemoteLoadSpy()
        let sut = SUT(
            localAgent: localAgentSpy,
            remoteLoad: remoteLoadSpy.process(_:completion:),
            fromModel: { .init(value: $0.value) },
            toModel: { .init(value: $0.value) }
        )
        
        // TODO: - fix memory leaks
        // trackForMemoryLeaks(sut, file: file, line: line)
        // trackForMemoryLeaks(localAgentSpy, file: file, line: line)
        // trackForMemoryLeaks(remoteLoadSpy, file: file, line: line)
        
        return (sut, localAgentSpy, remoteLoadSpy)
    }
    
    private struct Value: Equatable {
        
        let value: String
    }
    
    private func makeValue(
        _ value: String = anyMessage()
    ) -> Value {
        
        return .init(value: value)
    }
    
    private struct Model: Codable, Equatable {
        
        let value: String
    }
    
    private func makeModel(
        _ value: String = anyMessage()
    ) -> Model {
        
        return .init(value: value)
    }
    
    private func expect(
        _ load: Load<Value>,
        _ description: String = "wait for load completion",
        assert: @escaping ([Value]?) -> Void = { _ in },
        on action: () -> Void
    ) {
        let exp = expectation(description: description)
        
        load {
            
            assert($0)
            exp.fulfill()
        }
        
        // await actor thread-hop
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.1)
        
        action()
        
        wait(for: [exp], timeout: 1)
    }
}
