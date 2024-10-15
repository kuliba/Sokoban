//
//  SerialLoaderComposer+extWithLocalAgentTests.swift
//  ForaBankTests
//
//  Created by Igor Malyarov on 15.10.2024.
//

import ForaTools
@testable import ForaBank
import SerialComponents
import XCTest

final class SerialLoaderComposer_extWithLocalAgentTests: LocalAgentTests {
    
    func test_init_shouldNotCallCollaborators() {
        
        let (sut, remoteLoad) = makeSUT()
        
        XCTAssertEqual(remoteLoad.callCount, 0)
        XCTAssertNotNil(sut)
    }
    
    func test_load_shouldCallRemote() {
        
        let (sut, remoteLoad) = makeSUT()
        let exp = expectation(description: "wait for load completion")
        
        sut.compose().load { _ in exp.fulfill() }
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.1)
        
        remoteLoad.complete(with: .success(.init(value: [], serial: anyMessage())))
        
        wait(for: [exp], timeout: 1)
    }
    
    func test_load_shouldNotCallRemoteOnSecondLoad() {
        
        let (sut, remoteLoad) = makeSUT()
        let first = expectation(description: "wait for first load completion")
        
        sut.compose().load { _ in first.fulfill() }
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.1)
        
        remoteLoad.complete(with: .success(.init(value: [], serial: anyMessage())))
        
        wait(for: [first], timeout: 1)
        
        let second = expectation(description: "wait for second load completion")
        
        sut.compose().load { _ in second.fulfill() }
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.1)
        
        wait(for: [second], timeout: 1)
        
        XCTAssertEqual(remoteLoad.callCount, 1)
    }
    
    func test_reload_shouldCallRemote() {
        
        let (sut, remoteLoad) = makeSUT()
        let exp = expectation(description: "wait for reload completion")
        
        sut.compose().reload { _ in exp.fulfill() }
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.1)
        
        remoteLoad.complete(with: .success(.init(value: [], serial: anyMessage())))
        
        wait(for: [exp], timeout: 1)
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
}
