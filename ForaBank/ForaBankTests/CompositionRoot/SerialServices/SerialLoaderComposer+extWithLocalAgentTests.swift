//
//  SerialLoaderComposer+extWithLocalAgentTests.swift
//  VortexTests
//
//  Created by Igor Malyarov on 15.10.2024.
//

import VortexTools
@testable import Vortex
import SerialComponents
import XCTest

final class SerialLoaderComposer_extWithLocalAgentTests: LocalAgentTests {
    
    // MARK: - init
    
    func test_init_shouldNotCallCollaborators() {
        
        let (sut, remoteLoad) = makeSUT()
        
        XCTAssertEqual(remoteLoad.callCount, 0)
        XCTAssertNotNil(sut)
    }
    
    // MARK: - load
    
    func test_load_shouldCallRemote() {
        
        let (sut, remoteLoad) = makeSUT()
        
        sut.compose().load { _ in }
        // await actor thread-hop
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.1)
        
        XCTAssertEqual(remoteLoad.callCount, 1)
    }
    
    func test_load_shouldDeliverNilOnRemoteFailure() {
        
        let (sut, remoteLoad) = makeSUT()
        
        expect(sut.compose().load) {
            XCTAssertNoDiff($0, nil)
        } on: {
            remoteLoad.complete(with: anyError())
        }
    }
    
    func test_load_shouldDeliverEmptyOnRemoteEmpty() {
        
        let (sut, remoteLoad) = makeSUT()
        
        expect(sut.compose().load) {
            XCTAssertNoDiff($0, [])
        } on: {
            remoteLoad.complete(with: makeStamped([]))
        }
    }
    
    func test_load_shouldDeliverOneOnRemoteOne() {
        
        let values = [makeValue()]
        let (sut, remoteLoad) = makeSUT()
        
        expect(sut.compose().load) {
            XCTAssertNoDiff($0, values)
        } on: {
            remoteLoad.complete(with: makeStamped(values))
        }
    }
    
    func test_load_shouldDeliverTwoOnRemoteTwo() {
        
        let values = [makeValue(), makeValue()]
        let (sut, remoteLoad) = makeSUT()
        
        expect(sut.compose().load) {
            XCTAssertNoDiff($0, values)
        } on: {
            remoteLoad.complete(with: makeStamped(values))
        }
    }
    
    func test_load_shouldNotCallRemoteOnSecondLoad() {
        
        let (sut, remoteLoad) = makeSUT()
        
        expect(
            sut.compose().load,
            "wait for first load completion"
        ) {
            remoteLoad.complete(with: makeStamped([makeValue()]))
        }
        
        expect(sut.compose().load, "wait for second load completion") {}
        
        XCTAssertEqual(remoteLoad.callCount, 1)
    }
    
    func test_load_shouldDeliverEmptyOnSecondLoadOnRemoteEmpty() {
        
        let (sut, remoteLoad) = makeSUT()
        
        expect(
            sut.compose().load,
            "wait for first load completion"
        ) {
            XCTAssertNoDiff($0, [])
        } on: {
            remoteLoad.complete(with: makeStamped([]))
        }
        
        expect(
            sut.compose().load,
            "wait for second load completion"
        ) {
            XCTAssertNoDiff($0, [])
        } on: {}
        
        XCTAssertEqual(remoteLoad.callCount, 1)
    }
    
    func test_load_shouldDeliverOneOnSecondLoadOnRemoteOne() {
        
        let values = [makeValue()]
        let (sut, remoteLoad) = makeSUT()
        
        expect(
            sut.compose().load,
            "wait for first load completion"
        ) {
            XCTAssertNoDiff($0, values)
        } on: {
            remoteLoad.complete(with: makeStamped(values))
        }
        
        expect(
            sut.compose().load,
            "wait for second load completion"
        ) {
            XCTAssertNoDiff($0, values)
        } on: {}
        
        XCTAssertEqual(remoteLoad.callCount, 1)
    }
    
    func test_load_shouldDeliverTwoOnSecondLoadOnRemoteTwo() {
        
        let values = [makeValue(), makeValue()]
        let (sut, remoteLoad) = makeSUT()
        
        expect(
            sut.compose().load,
            "wait for first load completion"
        ) {
            XCTAssertNoDiff($0, values)
        } on: {
            remoteLoad.complete(with: makeStamped(values))
        }
        
        expect(
            sut.compose().load,
            "wait for second load completion"
        ) {
            XCTAssertNoDiff($0, values)
        } on: {}
        
        XCTAssertEqual(remoteLoad.callCount, 1)
    }
    
    // MARK: - reload
    
    func test_reload_shouldCallRemote() {
        
        let (sut, remoteLoad) = makeSUT()
        
        expect(sut.compose().reload) {
            
            remoteLoad.complete(with: makeStamped([]))
        }
    }
    
    // MARK: - Helpers
    
    private typealias Serial = String
    private typealias SUT = SerialComponents.SerialLoaderComposer<Serial, Value, Model>
    private typealias RemoteLoadSpy = Spy<Serial?, SerialStamped<Serial, [Value]>, Error>
    
    private func makeSUT(
        persisted loadStub: SerialStamped<Serial, [Model]>? = nil,
        storeStub: Result<Void, any Error> = .success(()),
        serialStub: String? = nil,
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        remoteLoadSpy: RemoteLoadSpy
    ) {
        let remoteLoadSpy = RemoteLoadSpy()
        let sut = SUT(
            localAgent: localAgent,
            remoteLoad: remoteLoadSpy.process(_:completion:),
            fromModel: { .init(value: $0.value) },
            toModel: { .init(value: $0.value) }
        )
        
        // TODO: - fix memory leaks
        // trackForMemoryLeaks(sut, file: file, line: line)
        // trackForMemoryLeaks(localAgentSpy, file: file, line: line)
        // trackForMemoryLeaks(remoteLoadSpy, file: file, line: line)
        
        return (sut, remoteLoadSpy)
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
    
    private func makeStamped<T>(
        _ value: [T],
        serial: Serial = anyMessage()
    ) -> SerialStamped<Serial, [T]> {
        
        return .init(value: value, serial: serial)
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
