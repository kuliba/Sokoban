//
//  SerialLoaderComposerTests.swift
//
//
//  Created by Igor Malyarov on 14.10.2024.
//

import ForaTools
import SerialComponents
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
    
    func test_load_shouldNotCallPersistentAndRemoteOnEmptyEphemeral() {
        
        let (sut, ephemeral, persistent, remoteLoad) = makeSUT()
        let load = sut.compose().load
        let exp = expectation(description: "wait for load completion")
        
        load { _ in exp.fulfill() }
        
        ephemeral.completeRetrieve(with: [])
        wait(for: [exp], timeout: 1)
        
        XCTAssertEqual(persistent.retrieveMessages.count, 0)
        XCTAssertEqual(remoteLoad.callCount, 0)
    }
    
    func test_load_shouldNotCallPersistentAndRemoteOnEphemeralWithOne() {
        
        let values = makeValuesModels(count: 1).values
        let (sut, ephemeral, persistent, remoteLoad) = makeSUT()
        let load = sut.compose().load
        let exp = expectation(description: "wait for load completion")
        
        load { _ in exp.fulfill() }
        
        ephemeral.completeRetrieve(with: values)
        wait(for: [exp], timeout: 1)
        
        XCTAssertEqual(persistent.retrieveMessages.count, 0)
        XCTAssertEqual(remoteLoad.callCount, 0)
    }
    
    func test_load_shouldNotCallPersistentAndRemoteOnEphemeralWithTwo() {
        
        let values = makeValuesModels(count: 2).values
        let (sut, ephemeral, persistent, remoteLoad) = makeSUT()
        let load = sut.compose().load
        let exp = expectation(description: "wait for load completion")
        
        load { _ in exp.fulfill() }
        
        ephemeral.completeRetrieve(with: values)
        wait(for: [exp], timeout: 1)
        
        XCTAssertEqual(persistent.retrieveMessages.count, 0)
        XCTAssertEqual(remoteLoad.callCount, 0)
    }
    
    func test_load_shouldDeliverEmptyOnEmptyEphemeral() {
        
        let (sut, ephemeral, _,_) = makeSUT()
        let load = sut.compose().load
        let exp = expectation(description: "wait for load completion")
        
        load {
            
            XCTAssertNoDiff($0, [])
            exp.fulfill()
        }
        
        ephemeral.completeRetrieve(with: [])
        wait(for: [exp], timeout: 1)
    }
    
    func test_load_shouldDeliverOneOnEphemeralWithOne() {
        
        let values = makeValuesModels(count: 1).values
        let (sut, ephemeral, _,_) = makeSUT()
        let load = sut.compose().load
        let exp = expectation(description: "wait for load completion")
        
        load {
            
            XCTAssertNoDiff($0, values)
            exp.fulfill()
        }
        
        ephemeral.completeRetrieve(with: values)
        wait(for: [exp], timeout: 1)
    }
    
    func test_load_shouldDeliverTwoOnEphemeralWithTwo() {
        
        let values = makeValuesModels(count: 2).values
        let (sut, ephemeral, _,_) = makeSUT()
        let load = sut.compose().load
        let exp = expectation(description: "wait for load completion")
        
        load {
            
            XCTAssertNoDiff($0, values)
            exp.fulfill()
        }
        
        ephemeral.completeRetrieve(with: values)
        wait(for: [exp], timeout: 1)
    }
    
    func test_load_shouldCallEphemeralWithEmptyOnEmptyPersistent() {
        
        let persisted = SerialStamped(value: [Model](), serial: anyMessage())
        let (sut, ephemeral, persistent, _) = makeSUT()
        let load = sut.compose().load
        let exp = expectation(description: "wait for load completion")
        
        load {
            
            XCTAssertNoDiff($0, [])
            exp.fulfill()
        }
        
        ephemeral.completeRetrieve(with: nil)
        persistent.completeRetrieve(with: persisted)
        ephemeral.completeInsertSuccessfully()
        
        wait(for: [exp], timeout: 1)
        
        XCTAssertEqual(ephemeral.insertMessages.map(\.value), [[]])
    }
    
    func test_load_shouldCallEphemeralWithOneOnPersistentWithOne() {
        
        let (values, models) = makeValuesModels(count: 1)
        let persisted = SerialStamped(value: models, serial: anyMessage())
        let (sut, ephemeral, persistent, _) = makeSUT()
        let load = sut.compose().load
        let exp = expectation(description: "wait for load completion")
        
        load {
            
            XCTAssertNoDiff($0, values)
            exp.fulfill()
        }
        
        ephemeral.completeRetrieve(with: nil)
        persistent.completeRetrieve(with: persisted)
        ephemeral.completeInsertSuccessfully()
        
        wait(for: [exp], timeout: 1)
        
        XCTAssertEqual(ephemeral.insertMessages.map(\.value), [values])
    }
    
    func test_load_shouldCallEphemeralWithTwoOnPersistentWithTwo() {
        
        let (values, models) = makeValuesModels(count: 2)
        let persisted = SerialStamped(value: models, serial: anyMessage())
        let (sut, ephemeral, persistent, _) = makeSUT()
        let load = sut.compose().load
        let exp = expectation(description: "wait for load completion")
        
        load {
            
            XCTAssertNoDiff($0, values)
            exp.fulfill()
        }
        
        ephemeral.completeRetrieve(with: nil)
        persistent.completeRetrieve(with: persisted)
        ephemeral.completeInsertSuccessfully()
        
        wait(for: [exp], timeout: 1)
        
        XCTAssertEqual(ephemeral.insertMessages.map(\.value), [values])
    }
    
    func test_load_shouldNotCallRemoteOnEmptyPersistent() {
        
        let persisted = SerialStamped(value: [Model](), serial: anyMessage())
        let (sut, ephemeral, persistent, remoteLoad) = makeSUT()
        let load = sut.compose().load
        let exp = expectation(description: "wait for load completion")
        
        load {
            
            XCTAssertNoDiff($0, [])
            exp.fulfill()
        }
        
        ephemeral.completeRetrieve(with: nil)
        persistent.completeRetrieve(with: persisted)
        ephemeral.completeInsertSuccessfully()
        
        wait(for: [exp], timeout: 1)
        
        XCTAssertEqual(remoteLoad.callCount, 0)
    }
    
    func test_load_shouldNotCallRemoteOnPersistentWithOne() {
        
        let (values, models) = makeValuesModels(count: 1)
        let persisted = SerialStamped(value: models, serial: anyMessage())
        let (sut, ephemeral, persistent, remoteLoad) = makeSUT()
        let load = sut.compose().load
        let exp = expectation(description: "wait for load completion")
        
        load {
            
            XCTAssertNoDiff($0, values)
            exp.fulfill()
        }
        
        ephemeral.completeRetrieve(with: nil)
        persistent.completeRetrieve(with: persisted)
        ephemeral.completeInsertSuccessfully()
        
        wait(for: [exp], timeout: 1)
        
        XCTAssertEqual(remoteLoad.callCount, 0)
    }
    
    func test_load_shouldNotCallRemoteOnPersistentWithTwo() {
        
        let (values, models) = makeValuesModels(count: 2)
        let persisted = SerialStamped(value: models, serial: anyMessage())
        let (sut, ephemeral, persistent, remoteLoad) = makeSUT()
        let load = sut.compose().load
        let exp = expectation(description: "wait for load completion")
        
        load {
            
            XCTAssertNoDiff($0, values)
            exp.fulfill()
        }
        
        ephemeral.completeRetrieve(with: nil)
        persistent.completeRetrieve(with: persisted)
        ephemeral.completeInsertSuccessfully()
        
        wait(for: [exp], timeout: 1)
        
        XCTAssertEqual(remoteLoad.callCount, 0)
    }
    
    func test_load_shouldCallRemoteOnEphemeralAndPersistentFailure() {
        
        let values = makeValuesModels(count: 2).values
        let (sut, ephemeral, persistent, remoteLoad) = makeSUT()
        let load = sut.compose().load
        let exp = expectation(description: "wait for load completion")
        
        load {
            
            XCTAssertNoDiff($0, values)
            exp.fulfill()
        }
        
        ephemeral.completeRetrieve(with: nil)
        persistent.completeRetrieve(with: nil)
        persistent.completeRetrieve(with: nil, at: 1)
        remoteLoad.complete(with: .success(.init(value: values, serial: anyMessage())))
        ephemeral.completeInsertSuccessfully()
        persistent.completeInsertSuccessfully()
        
        wait(for: [exp], timeout: 1)
    }
    
    // MARK: - reload
    
    func test_reload_shouldDeliverNilOnRemoteFailureWithNilSerial() {
        
        let (sut, _, persistent, remoteLoad) = makeSUT()
        let exp = expectation(description: "wait for load completion")
        
        sut.compose().reload {
            
            XCTAssertNil($0)
            exp.fulfill()
        }
        
        persistent.completeRetrieve(with: nil)
        remoteLoad.complete(with: .failure(anyError()))
        
        wait(for: [exp], timeout: 1)
    }
    
    func test_reload_shouldDeliverEmptyFromEphemeralOnRemoteFailureWithSerial() {
        
        let persisted = SerialStamped(value: [makeModel()], serial: anyMessage())
        let (sut, ephemeral, persistent, remoteLoad) = makeSUT()
        let exp = expectation(description: "wait for load completion")
        
        sut.compose().reload {
            
            XCTAssertNoDiff($0, [])
            exp.fulfill()
        }
        
        persistent.completeRetrieve(with: persisted)
        remoteLoad.complete(with: .failure(anyError()))
        ephemeral.completeRetrieve(with: [])
        
        wait(for: [exp], timeout: 1)
    }
    
    func test_reload_shouldDeliverOneFromEphemeralOnRemoteFailureWithSerial() {
        
        let values = makeValuesModels(count: 1).values
        let persisted = SerialStamped(value: [makeModel()], serial: anyMessage())
        let (sut, ephemeral, persistent, remoteLoad) = makeSUT()
        let exp = expectation(description: "wait for load completion")
        
        sut.compose().reload {
            
            XCTAssertNoDiff($0, values)
            exp.fulfill()
        }
        
        persistent.completeRetrieve(with: persisted)
        remoteLoad.complete(with: .failure(anyError()))
        ephemeral.completeRetrieve(with: values)
        
        wait(for: [exp], timeout: 1)
    }
    
    func test_reload_shouldDeliverTwoFromEphemeralOnRemoteFailureWithSerial() {
        
        let values = makeValuesModels(count: 2).values
        let persisted = SerialStamped(value: [makeModel()], serial: anyMessage())
        let (sut, ephemeral, persistent, remoteLoad) = makeSUT()
        let exp = expectation(description: "wait for load completion")
        
        sut.compose().reload {
            
            XCTAssertNoDiff($0, values)
            exp.fulfill()
        }
        
        persistent.completeRetrieve(with: persisted)
        remoteLoad.complete(with: .failure(anyError()))
        ephemeral.completeRetrieve(with: values)
        
        wait(for: [exp], timeout: 1)
    }
    
    func test_reload_shouldDeliverEmptyFromPersistentOnRemoteFailureWithSerialEmptyEphemeral() {
        
        let persisted = SerialStamped(value: [Model](), serial: anyMessage())
        let (sut, ephemeral, persistent, remoteLoad) = makeSUT()
        let exp = expectation(description: "wait for load completion")
        
        sut.compose().reload {
            
            XCTAssertNoDiff($0, [])
            exp.fulfill()
        }
        
        persistent.completeRetrieve(with: persisted)
        remoteLoad.complete(with: .failure(anyError()))
        ephemeral.completeRetrieve(with: nil)
        persistent.completeRetrieve(with: persisted, at: 1)
        ephemeral.completeInsertSuccessfully()
        
        wait(for: [exp], timeout: 1)
    }
    
    func test_reload_shouldDeliverOneFromPersistentOnRemoteFailureWithSerialEmptyEphemeral() {
        
        let (values, models) = makeValuesModels(count: 2)
        let persisted = SerialStamped(value: models, serial: anyMessage())
        let (sut, ephemeral, persistent, remoteLoad) = makeSUT()
        let exp = expectation(description: "wait for load completion")
        
        sut.compose().reload {
            
            XCTAssertNoDiff($0, values)
            exp.fulfill()
        }
        
        persistent.completeRetrieve(with: persisted)
        remoteLoad.complete(with: .failure(anyError()))
        ephemeral.completeRetrieve(with: nil)
        persistent.completeRetrieve(with: persisted, at: 1)
        ephemeral.completeInsertSuccessfully()
        
        wait(for: [exp], timeout: 1)
    }
    
    func test_reload_shouldDeliverTwoFromPersistentOnRemoteFailureWithSerialEmptyEphemeral() {
        
        let (values, models) = makeValuesModels(count: 2)
        let persisted = SerialStamped(value: models, serial: anyMessage())
        let (sut, ephemeral, persistent, remoteLoad) = makeSUT()
        let exp = expectation(description: "wait for load completion")
        
        sut.compose().reload {
            
            XCTAssertNoDiff($0, values)
            exp.fulfill()
        }
        
        persistent.completeRetrieve(with: persisted)
        remoteLoad.complete(with: .failure(anyError()))
        ephemeral.completeRetrieve(with: nil)
        persistent.completeRetrieve(with: persisted, at: 1)
        ephemeral.completeInsertSuccessfully()
        
        wait(for: [exp], timeout: 1)
    }
    
    func test_reload_shouldCallEphemeralAndPersistantWithEmptyOnRemoteSuccessEmptyWithNilSerial() {
        
        let serial = anyMessage()
        let (sut, ephemeral, persistent, remoteLoad) = makeSUT()
        let exp = expectation(description: "wait for load completion")
        
        sut.compose().reload {
            
            XCTAssertNoDiff($0, [])
            exp.fulfill()
        }
        
        persistent.completeRetrieve(with: nil)
        remoteLoad.complete(with: .success(.init(value: [], serial: serial)))
        ephemeral.completeInsertSuccessfully()
        persistent.completeInsertSuccessfully()
        
        wait(for: [exp], timeout: 1)
        
        XCTAssertNoDiff(ephemeral.insertMessages.map(\.value), [[]])
        XCTAssertNoDiff(persistent.insertMessages.map(\.value), [.init(value: [], serial: serial)])
    }
    
    func test_reload_shouldCallEphemeralAndPersistantWithOneOnRemoteSuccessOfOneWithNilSerial() {
        
        let serial = anyMessage()
        let (values, models) = makeValuesModels(count: 1)
        let (sut, ephemeral, persistent, remoteLoad) = makeSUT()
        let exp = expectation(description: "wait for load completion")
        
        sut.compose().reload {
            
            XCTAssertNoDiff($0, values)
            exp.fulfill()
        }
        
        persistent.completeRetrieve(with: nil)
        remoteLoad.complete(with: .success(.init(value: values, serial: serial)))
        ephemeral.completeInsertSuccessfully()
        persistent.completeInsertSuccessfully()
        
        wait(for: [exp], timeout: 1)
        
        XCTAssertNoDiff(ephemeral.insertMessages.map(\.value), [values])
        XCTAssertNoDiff(persistent.insertMessages.map(\.value), [.init(value: models, serial: serial)])
    }
    
    func test_reload_shouldCallEphemeralAndPersistantWithTwoOnRemoteSuccessOfTwoWithNilSerial() {
        
        let serial = anyMessage()
        let (values, models) = makeValuesModels(count: 2)
        let (sut, ephemeral, persistent, remoteLoad) = makeSUT()
        let exp = expectation(description: "wait for load completion")
        
        sut.compose().reload {
            
            XCTAssertNoDiff($0, values)
            exp.fulfill()
        }
        
        persistent.completeRetrieve(with: nil)
        remoteLoad.complete(with: .success(.init(value: values, serial: serial)))
        ephemeral.completeInsertSuccessfully()
        persistent.completeInsertSuccessfully()
        
        wait(for: [exp], timeout: 1)
        
        XCTAssertNoDiff(ephemeral.insertMessages.map(\.value), [values])
        XCTAssertNoDiff(persistent.insertMessages.map(\.value), [.init(value: models, serial: serial)])
    }
    
    func test_reload_shouldDeliverEmptyOnRemoteSuccessEmptyWithNilSerial() {
        
        let (sut, ephemeral, persistent, remoteLoad) = makeSUT()
        let exp = expectation(description: "wait for load completion")
        
        sut.compose().reload {
            
            XCTAssertNoDiff($0, [])
            exp.fulfill()
        }
        
        persistent.completeRetrieve(with: nil)
        remoteLoad.complete(with: .success(.init(value: [], serial: anyMessage())))
        ephemeral.completeInsertSuccessfully()
        persistent.completeInsertSuccessfully()
        
        wait(for: [exp], timeout: 1)
    }
    
    func test_reload_shouldDeliverOneOnRemoteSuccessOfOneWithNilSerial() {
        
        let values = makeValuesModels(count: 1).values
        let (sut, ephemeral, persistent, remoteLoad) = makeSUT()
        let exp = expectation(description: "wait for load completion")
        
        sut.compose().reload {
            
            XCTAssertNoDiff($0, values)
            exp.fulfill()
        }
        
        persistent.completeRetrieve(with: nil)
        remoteLoad.complete(with: .success(.init(value: values, serial: anyMessage())))
        ephemeral.completeInsertSuccessfully()
        persistent.completeInsertSuccessfully()
        
        wait(for: [exp], timeout: 1)
    }
    
    func test_reload_shouldDeliverTwoOnRemoteSuccessOfTwoWithNilSerial() {
        
        let values = makeValuesModels(count: 2).values
        let (sut, ephemeral, persistent, remoteLoad) = makeSUT()
        let exp = expectation(description: "wait for load completion")
        
        sut.compose().reload {
            
            XCTAssertNoDiff($0, values)
            exp.fulfill()
        }
        
        persistent.completeRetrieve(with: nil)
        remoteLoad.complete(with: .success(.init(value: values, serial: anyMessage())))
        ephemeral.completeInsertSuccessfully()
        persistent.completeInsertSuccessfully()
        
        wait(for: [exp], timeout: 1)
    }
    
    func test_reload_shouldDeliverEmptyFromRemoteOnRemoteSuccessWithDifferentSerial() {
        
        let values = [Value]()
        let (sut, ephemeral, persistent, remoteLoad) = makeSUT()
        let exp = expectation(description: "wait for load completion")
        
        sut.compose().reload {
            
            XCTAssertNoDiff($0, values)
            exp.fulfill()
        }
        
        persistent.completeRetrieve(with: .init(value: [], serial: anyMessage()))
        remoteLoad.complete(with: .success(.init(value: values, serial: anyMessage())))
        ephemeral.completeInsertSuccessfully()
        persistent.completeInsertSuccessfully()
        
        wait(for: [exp], timeout: 1)
    }
    
    func test_reload_shouldDeliverOneFromRemoteOnRemoteSuccessWithDifferentSerial() {
        
        let values = makeValuesModels(count: 1).values
        let (sut, ephemeral, persistent, remoteLoad) = makeSUT()
        let exp = expectation(description: "wait for load completion")
        
        sut.compose().reload {
            
            XCTAssertNoDiff($0, values)
            exp.fulfill()
        }
        
        persistent.completeRetrieve(with: .init(value: [], serial: anyMessage()))
        remoteLoad.complete(with: .success(.init(value: values, serial: anyMessage())))
        ephemeral.completeInsertSuccessfully()
        persistent.completeInsertSuccessfully()
        
        wait(for: [exp], timeout: 1)
    }
    
    func test_reload_shouldDeliverTwoFromRemoteOnRemoteSuccessWithDifferentSerial() {
        
        let values = makeValuesModels(count: 2).values
        let (sut, ephemeral, persistent, remoteLoad) = makeSUT()
        let exp = expectation(description: "wait for load completion")
        
        sut.compose().reload {
            
            XCTAssertNoDiff($0, values)
            exp.fulfill()
        }
        
        persistent.completeRetrieve(with: .init(value: [], serial: anyMessage()))
        remoteLoad.complete(with: .success(.init(value: values, serial: anyMessage())))
        ephemeral.completeInsertSuccessfully()
        persistent.completeInsertSuccessfully()
        
        wait(for: [exp], timeout: 1)
    }
    
    // MARK: - Helpers
    
    private typealias Serial = String
    private typealias SUT = SerialLoaderComposer<Serial, Value, Model>
    private typealias RemoteLoadSpy = Spy<Serial?, Result<SerialStamped<Serial, [Value]>, Error>>
    private typealias EphemeralSpy = MonolithicStoreSpy<[Value]>
    private typealias PersistentSpy = MonolithicStoreSpy<SerialStamped<Serial, [Model]>>
    
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
        
        // TODO: fix memory leaks
        //    trackForMemoryLeaks(sut, file: file, line: line)
        //    trackForMemoryLeaks(ephemeralSpy, file: file, line: line)
        //    trackForMemoryLeaks(persistentSpy, file: file, line: line)
        //    trackForMemoryLeaks(remoteLoadSpy, file: file, line: line)
        
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
    
    private func makeValuesModels(
        count: Int
    ) -> (values: [Value], models: [Model]) {
        
        let content = (0..<count).map { _ in anyMessage() }
        let values = content.map(makeValue(_:))
        let models = content.map(makeModel(_:))
        
        XCTAssertEqual(values.count, count)
        XCTAssertEqual(models.count, count)
        
        return (values, models)
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
