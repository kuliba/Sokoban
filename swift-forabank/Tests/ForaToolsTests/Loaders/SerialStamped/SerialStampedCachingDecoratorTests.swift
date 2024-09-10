//
//  SerialStampedCachingDecoratorTests.swift
//
//
//  Created by Igor Malyarov on 10.09.2024.
//

final class SerialStampedCachingDecorator<Payload, Response> {
    
    private let decoratee: Decoratee
    private let cache: Cache
    
    init(
        decoratee: @escaping Decoratee,
        cache: @escaping Cache
    ) {
        self.decoratee = decoratee
        self.cache = cache
    }
    
    typealias DecorateeCompletion = (Result<SerialStamped<Response>, Error>) -> Void
    typealias Decoratee = (SerialStamped<Payload>, @escaping DecorateeCompletion) -> Void
    typealias CacheCompletion = (Result<Void, Error>) -> Void
    typealias Cache = (SerialStamped<Response>, @escaping CacheCompletion) -> Void
}

extension SerialStampedCachingDecorator {
    
    func load(
        _ payload: SerialStamped<Payload>,
        completion: @escaping DecorateeCompletion
    ) {
        decoratee(payload) { [weak self] in
            
            guard let self else { return }
        
            switch $0 {
            case let .failure(failure):
                completion(.failure(failure))
                
            case let .success(success):
                if success.serial != payload.serial {
                    self.cache(success) { _ in completion(.success(success)) }
                } else {
                    completion(.success(success))
                }
            }
        }
    }
}

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
        
        let payload = makeLoadPayload()
        let (sut, loadSpy, _) = makeSUT()
        
        sut.load(payload) { _ in }
        
        XCTAssertNoDiff(loadSpy.payloads, [payload])
    }
    
    func test_load_shouldNotCallCacheOnLoadFailure() {
        
        let (sut, loadSpy, cacheSpy) = makeSUT()
        
        sut.load(makeLoadPayload()) { _ in }
        loadSpy.complete(with: .failure(anyError()))
        
        XCTAssertEqual(cacheSpy.callCount, 0)
    }
    
    func test_load_shouldDeliverFailureOnLoadFailure() {
        
        let (sut, loadSpy, _) = makeSUT()
        let exp = expectation(description: "wait for load completion")

        sut.load(makeLoadPayload()) {
            
            switch $0 {
            case .failure:
                break
                
            default:
                XCTFail("Expected failure, got \($0) instead.")
            }
            exp.fulfill()
        }
        
        loadSpy.complete(with: .failure(anyError()))
        
        wait(for: [exp], timeout: 0.1)
    }
    
    func test_load_shouldNotDeliverFailureOnInstanceDeallocation() {
        
        var sut: SUT?
        let loadSpy: LoadSpy
        (sut, loadSpy, _) = makeSUT()
        let exp = expectation(description: "wait for load completion")
        exp.isInverted = true
        
        sut?.load(makeLoadPayload()) { _ in exp.fulfill() }
        sut = nil
        loadSpy.complete(with: .failure(anyError()))
        
        wait(for: [exp], timeout: 0.1)
    }
    
    func test_load_shouldNotCallCacheOnSameLoadedSerial() {
        
        let serial = anyMessage()
        let (sut, loadSpy, cacheSpy) = makeSUT()
        
        sut.load(makeLoadPayload(serial: serial)) { _ in }
        loadSpy.complete(with: .success(makeLoadResponse(serial: serial)))
        
        XCTAssertEqual(cacheSpy.callCount, 0)
    }
    
    func test_load_shouldDeliverLoadedOnSameLoadedSerial() {
        
        let serial = anyMessage()
        let response = makeLoadResponse(serial: serial)
        let (sut, loadSpy, _) = makeSUT()
        let exp = expectation(description: "wait for load completion")
        
        sut.load(makeLoadPayload(serial: serial)) {
            
            switch $0 {
            case let .success(receivedResponse):
                XCTAssertNoDiff(receivedResponse, response)
                
            default:
                XCTFail("Expected success, got \($0) instead.")
            }
            exp.fulfill()
        }
        
        loadSpy.complete(with: .success(response))
        
        wait(for: [exp], timeout: 0.1)
    }
    
    func test_load_shouldNotDeliverSuccessOnInstanceDeallocation() {
        
        var sut: SUT?
        let loadSpy: LoadSpy
        (sut, loadSpy, _) = makeSUT()
        let exp = expectation(description: "wait for load completion")
        exp.isInverted = true
        
        sut?.load(makeLoadPayload()) { _ in exp.fulfill() }
        sut = nil
        loadSpy.complete(with: .success(makeLoadResponse()))
        
        wait(for: [exp], timeout: 0.1)
    }
    
    func test_load_shouldCallCacheOnDifferentLoadedSerial() {
        
        let (oldSerial, newSerial) = (anyMessage(), anyMessage())
        let (sut, loadSpy, cacheSpy) = makeSUT()
        
        sut.load(makeLoadPayload(serial: oldSerial)) { _ in }
        loadSpy.complete(with: .success(makeLoadResponse(serial: newSerial)))
        
        XCTAssertEqual(cacheSpy.callCount, 1)
        XCTAssertNotEqual(oldSerial, newSerial)
    }
    
    func test_load_shouldCallCacheOnDifferentLoadedSerialWithLoaded() {
        
        let (oldSerial, newSerial) = (anyMessage(), anyMessage())
        let response = makeLoadResponse(serial: newSerial)
        let (sut, loadSpy, cacheSpy) = makeSUT()
        
        sut.load(makeLoadPayload(serial: oldSerial)) { _ in }
        loadSpy.complete(with: .success(response))
        
        XCTAssertEqual(cacheSpy.payloads, [response])
        XCTAssertNotEqual(oldSerial, newSerial)
    }
    
    func test_load_shouldDeliverLoadedOnDifferentLoadedSerialCacheFailure() {
        
        let (oldSerial, newSerial) = (anyMessage(), anyMessage())
        let response = makeLoadResponse(serial: newSerial)
        let (sut, loadSpy, cacheSpy) = makeSUT()
        let exp = expectation(description: "wait for load and cache completion")
        
        sut.load(makeLoadPayload(serial: oldSerial)) {
            
            switch $0 {
            case let .success(receivedResponse):
                XCTAssertNoDiff(receivedResponse, response)
                
            default:
                XCTFail("Expected success, got \($0) instead.")
            }
            exp.fulfill()
        }
        
        loadSpy.complete(with: .success(response))
        cacheSpy.complete(with: .failure(anyError()))
        
        wait(for: [exp], timeout: 0.1)

        XCTAssertNotEqual(oldSerial, newSerial)
    }
    
    func test_load_shouldDeliverLoadedOnDifferentLoadedSerialCacheSuccess() {
        
        let (oldSerial, newSerial) = (anyMessage(), anyMessage())
        let response = makeLoadResponse(serial: newSerial)
        let (sut, loadSpy, cacheSpy) = makeSUT()
        let exp = expectation(description: "wait for load and cache completion")
        
        sut.load(makeLoadPayload(serial: oldSerial)) {
            
            switch $0 {
            case let .success(receivedResponse):
                XCTAssertNoDiff(receivedResponse, response)
                
            default:
                XCTFail("Expected success, got \($0) instead.")
            }
            exp.fulfill()
        }
        
        loadSpy.complete(with: .success(response))
        cacheSpy.complete(with: .success(()))
        
        wait(for: [exp], timeout: 0.1)

        XCTAssertNotEqual(oldSerial, newSerial)
    }
    
    // MARK: - Helpers
    
    private typealias SUT = SerialStampedCachingDecorator<Payload, Response>
    private typealias LoadSpy = Spy<SerialStamped<Payload>, Result<SerialStamped<Response>, Error>>
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
    
    private struct Payload: Equatable {
        
        let serial: String
    }
    
    private func makePayload(
        serial: String = anyMessage()
    ) -> Payload {
        
        return .init(serial: serial)
    }
    
    private func makeLoadPayload(
        serial: String = anyMessage(),
        value: Payload? = nil
    ) -> SerialStamped<Payload> {
        
        return .init(value: value ?? makePayload(), serial: serial)
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
}
