//
//  ConvenienceSerialStampedCachingDecoratorTests.swift
//
//
//  Created by Igor Malyarov on 10.09.2024.
//

import SerialComponents
import VortexTools
import XCTest

final class ConvenienceSerialStampedCachingDecoratorTests: XCTestCase {
    
    // MARK: - init
    
    func test_init_shouldNotCallDecoratee() {
        
        let (sut, loadSpy, updateSpy) = makeSUT()
        
        XCTAssertEqual(loadSpy.callCount, 0)
        XCTAssertEqual(updateSpy.callCount, 0)
        XCTAssertNotNil(sut)
    }
    
    // MARK: - decorated
    
    func test_decorated_shouldCallDecorateeWithCategory() {
        
        let category = makeCategory()
        let (sut, loadSpy, _) = makeSUT()
        
        sut(category) { _ in }
        
        XCTAssertNoDiff(loadSpy.payloads.map(\.0), [category])
    }
    
    func test_decorated_shouldCallDecorateeWithoutSerial_onEmptyInitialStorage() {
        
        let category = makeCategory()
        let (sut, loadSpy, _) = makeSUT()
        
        sut(category) { _ in }
        
        XCTAssertNoDiff(loadSpy.payloads.map(\.1), [nil])
    }
    
    func test_decorated_shouldCallDecorateeWithoutSerial_onNonMatchingInitialStorage() {
        
        let category = makeCategory()
        let (sut, loadSpy, _) = makeSUT(initialStorage: makeStorage(
            items: [makeItem(category: makeCategory())]
        ))
        
        sut(category) { _ in }
        
        XCTAssertNoDiff(loadSpy.payloads.map(\.1), [nil])
    }
    
    func test_decorated_shouldCallDecorateeWithSerial_onMatchingInitialStorage() {
        
        let category = makeCategory()
        let serial = anyMessage()
        let (sut, loadSpy, _) = makeSUT(initialStorage: makeStorage(
            items: [makeItem(category: category)],
            serial: serial
        ))
        
        sut(category) { _ in }
        
        XCTAssertNoDiff(loadSpy.payloads.map(\.1), [serial])
    }
    
    func test_decorated_shouldNotCallCacheOnLoadFailure() {
        
        let (sut, loadSpy, updateSpy) = makeSUT()
        
        sut(makeCategory()) { _ in }
        loadSpy.complete(with: .failure(anyError()))
        
        XCTAssertEqual(updateSpy.callCount, 0)
    }
    
    func test_decorated_shouldDeliverFailureOnLoadFailure() {
        
        let (sut, loadSpy, _) = makeSUT()
        
        expect(sut, with: makeCategory(), toDeliver: .failure(anyError())) {
            
            loadSpy.complete(with: .failure(anyError()))
        }
    }
    
    func test_decorated_shouldNotDeliverFailureOnInstanceDeallocation() {
        
        var sut: SUT?
        let loadSpy: LoadSpy
        (sut, loadSpy, _) = makeSUT()
        let exp = expectation(description: "wait for load completion")
        exp.isInverted = true
        
        sut?(makeCategory()) { _ in exp.fulfill() }
        sut = nil
        loadSpy.complete(with: .failure(anyError()))
        
        wait(for: [exp], timeout: 0.1)
    }
    
    func test_decorated_shouldNotDeliverSuccessOnInstanceDeallocation() {
        
        var sut: SUT?
        let loadSpy: LoadSpy
        (sut, loadSpy, _) = makeSUT()
        let exp = expectation(description: "wait for load completion")
        exp.isInverted = true
        
        sut?(makeCategory()) { _ in exp.fulfill() }
        sut = nil
        loadSpy.complete(with: .success(makeLoadResponse()))
        
        wait(for: [exp], timeout: 0.1)
    }
    
    func test_decorated_shouldCallCacheOnDifferentLoadedSerial() {
        
        let (oldSerial, newSerial) = (anyMessage(), anyMessage())
        let (sut, loadSpy, updateSpy) = makeSUT()
        
        sut(makeCategory()) { _ in }
        loadSpy.complete(with: .success(makeLoadResponse(serial: newSerial)))
        
        XCTAssertEqual(updateSpy.callCount, 1)
        XCTAssertNotEqual(oldSerial, newSerial)
    }
    
    func test_decorated_shouldCallCacheOnDifferentLoadedSerialWithLoaded() {
        
        let category = makeCategory()
        let (oldSerial, newSerial) = (anyMessage(), anyMessage())
        let response = makeLoadResponse(serial: newSerial)
        let (sut, loadSpy, updateSpy) = makeSUT()
        
        sut(category) { _ in }
        loadSpy.complete(with: .success(response))
        
        XCTAssertEqual(updateSpy.payloads, [.init(items: response.value, serial: newSerial)])
        XCTAssertNotEqual(oldSerial, newSerial)
    }
    
    func test_decorated_shouldDeliverLoadedOnDifferentLoadedSerial() {
        
        let response = makeLoadResponse(serial: anyMessage())
        let (sut, loadSpy, updateSpy) = makeSUT()
        
        expect(sut, with: makeCategory(), toDeliver: .success(response)) {
            
            loadSpy.complete(with: .success(response))
            updateSpy.complete()
        }
    }
    
    // MARK: - Helpers
    
    private typealias Serial = String
    private typealias SUT = SerialStampedCachingDecorator<Category, Serial, [Item]>
    
    private typealias Storage = CategorizedStorage<Category, Item>
    private typealias LoadSpy = Spy<(Category, Serial?), Result<SerialStamped<String, [Item]>, Error>>
    private typealias UpdateSpy = Spy<CategorizedStorage<Category, Item>, Void>
    
    private func makeSUT(
        initialStorage: Storage? = nil,
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        loadSpy: LoadSpy,
        updateSpy: UpdateSpy
    ) {
        let loadSpy = LoadSpy()
        let updateSpy = UpdateSpy()
        let sut = SUT(
            initialStorage: initialStorage,
            loadItems: loadSpy.process,
            update: updateSpy.process
        )
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(loadSpy, file: file, line: line)
        trackForMemoryLeaks(updateSpy, file: file, line: line)
        
        return (sut, loadSpy, updateSpy)
    }
    
    private func makeStorage(
        items: [Item]? = nil,
        serial: String = anyMessage()
    ) -> Storage {
        
        return .init(items: items ?? [makeItem()], serial: serial)
    }
    
    private struct Category: Hashable {
        
        let value: String
    }
    
    private func makeCategory(
        _ value: String = anyMessage()
    ) -> Category {
        
        return .init(value: value)
    }
    
    private struct Item: Equatable, Categorized {
        
        let category: Category
        let value: String
    }
    
    private func makeItem(
        category: Category? = nil,
        _ value: String = anyMessage()
    ) -> Item {
        
        return .init(category: category ?? makeCategory(), value: value)
    }
    
    private func makeLoadResponse(
        serial: String = anyMessage(),
        items: [Item]? = nil
    ) -> SerialStamped<Serial, [Item]> {
        
        return .init(value: items ?? [makeItem()], serial: serial)
    }
    
    private func expect(
        _ sut: SUT,
        with category: Category,
        toDeliver expectedResult: Result<SerialStamped<Serial, [Item]>, Error>,
        on action: () -> Void,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let exp = expectation(description: "wait for load completion")
        
        sut.decorated(category) {
            
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
