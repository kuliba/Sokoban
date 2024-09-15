//
//  SerialStampedCachingDecoratorTests.swift
//
//
//  Created by Igor Malyarov on 10.09.2024.
//

import ForaTools
import XCTest

final class SerialStampedCachingDecoratorTests: XCTestCase {
    
    // MARK: - init
    
    func test_init_shouldNotCallDecoratee() {
        
        let (sut, loadSpy, cacheSpy) = makeSUT()
        
        XCTAssertEqual(loadSpy.callCount, 0)
        XCTAssertEqual(cacheSpy.callCount, 0)
        XCTAssertNotNil(sut)
    }
    
    // MARK: - decorated
    
    func test_decorated_shouldCallDecorateeWithPayload() {
        
        let serial = anyMessage()
        let (sut, loadSpy, _) = makeSUT()
        
        sut(serial) { _ in }
        
        XCTAssertNoDiff(loadSpy.payloads.map(\.serial), [serial])
    }
    
    func test_decorated_shouldNotCallCacheOnLoadFailure() {
        
        let (sut, loadSpy, cacheSpy) = makeSUT()
        
        sut(anyMessage()) { _ in }
        loadSpy.complete(with: .failure(anyError()))
        
        XCTAssertEqual(cacheSpy.callCount, 0)
    }
    
    func test_decorated_shouldDeliverFailureOnLoadFailure() {
        
        let (sut, loadSpy, _) = makeSUT()
        
        expect(sut, with: anyMessage(), toDeliver: .failure(anyError())) {
            
            loadSpy.complete(with: .failure(anyError()))
        }
    }
    
    func test_decorated_shouldNotDeliverFailureOnInstanceDeallocation() {
        
        var sut: SUT?
        let loadSpy: LoadSpy
        (sut, loadSpy, _) = makeSUT()
        let exp = expectation(description: "wait for load completion")
        exp.isInverted = true
        
        sut?(.init(anyMessage())) { _ in exp.fulfill() }
        sut = nil
        loadSpy.complete(with: .failure(anyError()))
        
        wait(for: [exp], timeout: 0.1)
    }
    
    func test_decorated_shouldNotCallCacheOnSameLoadedSerial() {
        
        let serial = anyMessage()
        let (sut, loadSpy, cacheSpy) = makeSUT()
        
        sut(serial) { _ in }
        loadSpy.complete(with: .success(makeLoadResponse(serial: serial)))
        
        XCTAssertEqual(cacheSpy.callCount, 0)
    }
    
    func test_decorated_shouldDeliverLoadedOnSameLoadedSerial() {
        
        let serial = anyMessage()
        let response = makeLoadResponse(serial: serial)
        let (sut, loadSpy, _) = makeSUT()
        
        expect(sut, with: serial, toDeliver: .success(response)) {
            
            loadSpy.complete(with: .success(response))
        }
    }
    
    func test_decorated_shouldNotDeliverSuccessOnInstanceDeallocation() {
        
        var sut: SUT?
        let loadSpy: LoadSpy
        (sut, loadSpy, _) = makeSUT()
        let exp = expectation(description: "wait for load completion")
        exp.isInverted = true
        
        sut?(.init(anyMessage())) { _ in exp.fulfill() }
        sut = nil
        loadSpy.complete(with: .success(makeLoadResponse()))
        
        wait(for: [exp], timeout: 0.1)
    }
    
    func test_decorated_shouldCallCacheOnDifferentLoadedSerial() {
        
        let (oldSerial, newSerial) = (anyMessage(), anyMessage())
        let (sut, loadSpy, cacheSpy) = makeSUT()
        
        sut(oldSerial) { _ in }
        loadSpy.complete(with: .success(makeLoadResponse(serial: newSerial)))
        
        XCTAssertEqual(cacheSpy.callCount, 1)
        XCTAssertNotEqual(oldSerial, newSerial)
    }
    
    func test_decorated_shouldCallCacheOnDifferentLoadedSerialWithLoaded() {
        
        let (oldSerial, newSerial) = (anyMessage(), anyMessage())
        let response = makeLoadResponse(serial: newSerial)
        let (sut, loadSpy, cacheSpy) = makeSUT()
        
        sut(oldSerial) { _ in }
        loadSpy.complete(with: .success(response))
        
        XCTAssertEqual(cacheSpy.payloads, [response])
        XCTAssertNotEqual(oldSerial, newSerial)
    }
    
    func test_decorated_shouldDeliverLoadedOnDifferentLoadedSerialCacheFailure() {
        
        let (oldSerial, newSerial) = (anyMessage(), anyMessage())
        let response = makeLoadResponse(serial: newSerial)
        let (sut, loadSpy, cacheSpy) = makeSUT()
        
        expect(sut, with: oldSerial, toDeliver: .success(response)) {
            
            loadSpy.complete(with: .success(response))
            cacheSpy.complete(with: .failure(anyError()))
        }
    }
    
    func test_decorated_shouldDeliverLoadedOnDifferentLoadedSerialCacheSuccess() {
        
        let (oldSerial, newSerial) = (anyMessage(), anyMessage())
        let response = makeLoadResponse(serial: newSerial)
        let (sut, loadSpy, cacheSpy) = makeSUT()
        
        expect(sut, with: oldSerial, toDeliver: .success(response)) {
            
            loadSpy.complete(with: .success(response))
            cacheSpy.complete(with: .success(()))
        }
    }
    
    // MARK: - Helpers
    
    private typealias Serial = String
    private typealias SUT = SerialStampedCachingDecorator<Serial, Value>
    private typealias LoadSpy = Spy<SUT.Payload, Result<SerialStamped<String, Value>, Error>>
    private typealias CacheSpy = Spy<SerialStamped<String, Value>, Result<Void, Error>>
    
    private func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        loadSpy: LoadSpy,
        cacheSpy: CacheSpy
    ) {
        let loadSpy = LoadSpy()
        let cacheSpy = CacheSpy()
        let sut = SUT(
            decoratee: loadSpy.process,
            cache: cacheSpy.process
        )
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(loadSpy, file: file, line: line)
        trackForMemoryLeaks(cacheSpy, file: file, line: line)
        
        return (sut, loadSpy, cacheSpy)
    }
    
    private struct Value: Equatable {
        
        let serial: String
    }
    
    private func makeValue(
        serial: String = anyMessage()
    ) -> Value {
        
        return .init(serial: serial)
    }
    
    private func makeLoadResponse(
        serial: String = anyMessage(),
        value: Value? = nil
    ) -> SerialStamped<String, Value> {
        
        return .init(value: value ?? makeValue(), serial: serial)
    }
    
    private func expect(
        _ sut: SUT,
        with serial: String?,
        toDeliver expectedResult: Result<SerialStamped<String, Value>, Error>,
        on action: () -> Void,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let exp = expectation(description: "wait for load completion")
        
        sut(serial) {
            
            switch ($0, expectedResult) {
            case (.failure, .failure):
                break
                
            case let (.success(receivedResponse), .success(expectedResponse)):
                XCTAssertNoDiff(receivedResponse, expectedResponse, file: file, line: line)
                
            default:
                XCTFail("Expected \(expectedResult), got \($0) instead.")
            }
            
            exp.fulfill()
        }
        
        action()
        
        wait(for: [exp], timeout: 0.1)
    }
}
