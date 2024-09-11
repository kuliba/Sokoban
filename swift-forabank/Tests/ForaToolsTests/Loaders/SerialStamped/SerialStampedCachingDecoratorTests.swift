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
    
    // MARK: - load
    
    func test_load_shouldCallDecorateeWithPayload() {
        
        let serial = anyMessage()
        let (sut, loadSpy, _) = makeSUT()
        
        sut.load(serial) { _ in }
        
        XCTAssertNoDiff(loadSpy.payloads, [serial])
    }
    
    func test_load_shouldNotCallCacheOnLoadFailure() {
        
        let (sut, loadSpy, cacheSpy) = makeSUT()
        
        sut.load(anyMessage()) { _ in }
        loadSpy.complete(with: .failure(anyError()))
        
        XCTAssertEqual(cacheSpy.callCount, 0)
    }
    
    func test_load_shouldDeliverFailureOnLoadFailure() {
        
        let (sut, loadSpy, _) = makeSUT()
        
        expect(sut, with: anyMessage(), toDeliver: .failure(anyError())) {
            
            loadSpy.complete(with: .failure(anyError()))
        }
    }
    
    func test_load_shouldNotDeliverFailureOnInstanceDeallocation() {
        
        var sut: SUT?
        let loadSpy: LoadSpy
        (sut, loadSpy, _) = makeSUT()
        let exp = expectation(description: "wait for load completion")
        exp.isInverted = true
        
        sut?.load(anyMessage()) { _ in exp.fulfill() }
        sut = nil
        loadSpy.complete(with: .failure(anyError()))
        
        wait(for: [exp], timeout: 0.1)
    }
    
    func test_load_shouldNotCallCacheOnSameLoadedSerial() {
        
        let serial = anyMessage()
        let (sut, loadSpy, cacheSpy) = makeSUT()
        
        sut.load(serial) { _ in }
        loadSpy.complete(with: .success(makeLoadResponse(serial: serial)))
        
        XCTAssertEqual(cacheSpy.callCount, 0)
    }
    
    func test_load_shouldDeliverLoadedOnSameLoadedSerial() {
        
        let serial = anyMessage()
        let response = makeLoadResponse(serial: serial)
        let (sut, loadSpy, _) = makeSUT()
        
        expect(sut, with: serial, toDeliver: .success(response)) {
            
            loadSpy.complete(with: .success(response))
        }
    }
    
    func test_load_shouldNotDeliverSuccessOnInstanceDeallocation() {
        
        var sut: SUT?
        let loadSpy: LoadSpy
        (sut, loadSpy, _) = makeSUT()
        let exp = expectation(description: "wait for load completion")
        exp.isInverted = true
        
        sut?.load(anyMessage()) { _ in exp.fulfill() }
        sut = nil
        loadSpy.complete(with: .success(makeLoadResponse()))
        
        wait(for: [exp], timeout: 0.1)
    }
    
    func test_load_shouldCallCacheOnDifferentLoadedSerial() {
        
        let (oldSerial, newSerial) = (anyMessage(), anyMessage())
        let (sut, loadSpy, cacheSpy) = makeSUT()
        
        sut.load(oldSerial) { _ in }
        loadSpy.complete(with: .success(makeLoadResponse(serial: newSerial)))
        
        XCTAssertEqual(cacheSpy.callCount, 1)
        XCTAssertNotEqual(oldSerial, newSerial)
    }
    
    func test_load_shouldCallCacheOnDifferentLoadedSerialWithLoaded() {
        
        let (oldSerial, newSerial) = (anyMessage(), anyMessage())
        let response = makeLoadResponse(serial: newSerial)
        let (sut, loadSpy, cacheSpy) = makeSUT()
        
        sut.load(oldSerial) { _ in }
        loadSpy.complete(with: .success(response))
        
        XCTAssertEqual(cacheSpy.payloads, [response])
        XCTAssertNotEqual(oldSerial, newSerial)
    }
    
    func test_load_shouldDeliverLoadedOnDifferentLoadedSerialCacheFailure() {
        
        let (oldSerial, newSerial) = (anyMessage(), anyMessage())
        let response = makeLoadResponse(serial: newSerial)
        let (sut, loadSpy, cacheSpy) = makeSUT()
        
        expect(sut, with: oldSerial, toDeliver: .success(response)) {
            
            loadSpy.complete(with: .success(response))
            cacheSpy.complete(with: .failure(anyError()))
        }
    }
    
    func test_load_shouldDeliverLoadedOnDifferentLoadedSerialCacheSuccess() {
        
        let (oldSerial, newSerial) = (anyMessage(), anyMessage())
        let response = makeLoadResponse(serial: newSerial)
        let (sut, loadSpy, cacheSpy) = makeSUT()
        
        expect(sut, with: oldSerial, toDeliver: .success(response)) {
            
            loadSpy.complete(with: .success(response))
            cacheSpy.complete(with: .success(()))
        }
    }
    
    // MARK: - Helpers
    
    private typealias SUT = SerialStampedCachingDecorator<Response>
    private typealias LoadSpy = Spy<String?, Result<SerialStamped<Response>, Error>>
    private typealias CacheSpy = Spy<SerialStamped<Response>, Result<Void, Error>>
    
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
    
    private struct Response: Equatable {
        
        let serial: String
    }
    
    private func makeResponse(
        serial: String = anyMessage()
    ) -> Response {
        
        return .init(serial: serial)
    }
    
    private func makeLoadResponse(
        serial: String = anyMessage(),
        value: Response? = nil
    ) -> SerialStamped<Response> {
        
        return .init(value: value ?? makeResponse(), serial: serial)
    }
    
    private func expect(
        _ sut: SUT,
        with serial: String?,
        toDeliver expectedResult: Result<SerialStamped<Response>, Error>,
        on action: () -> Void,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let exp = expectation(description: "wait for load completion")

        sut.load(serial) {
            
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
