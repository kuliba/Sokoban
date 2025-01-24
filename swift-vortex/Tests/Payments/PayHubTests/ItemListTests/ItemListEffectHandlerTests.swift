//
//  ItemListEffectHandlerTests.swift
//
//
//  Created by Igor Malyarov on 17.01.2025.
//

import PayHub
import XCTest

final class ItemListEffectHandlerTests: ItemListTests {
    
    // MARK: - init
    
    func test_init_shouldNotCallCollaborator() {
        
        let (sut, loadSpy, reloadSpy) = makeSUT()
        
        XCTAssertEqual(loadSpy.callCount, 0)
        XCTAssertEqual(reloadSpy.callCount, 0)
        XCTAssertNotNil(sut)
    }
    
    // MARK: - load
    
    func test_load_shouldCallLoad() {
        
        let (sut, loadSpy, _) = makeSUT()
        
        sut.handleEffect(.load) { _ in }
        
        XCTAssertEqual(loadSpy.callCount, 1)
    }
    
    func test_load_shouldPassNotifyToLoad() {
        
        let id = anyMessage()
        let (sut, loadSpy, _) = makeSUT()
        var receivedEvents = [SUT.Event]()
        
        sut.handleEffect(.load) { receivedEvents.append($0) }
        loadSpy.payloads.first?(.update(state: .completed, forID: id))
        
        XCTAssertNoDiff(receivedEvents, [.update(state: .completed, forID: id)])
    }
    
    func test_load_shouldNotDeliverResultOnInstanceDeallocation() throws {
        
        var sut: SUT?
        let loadSpy: LoadSpy
        (sut, loadSpy, _) = makeSUT()
        let exp = expectation(description: "completion should not be called")
        exp.isInverted = true
        
        sut?.handleEffect(.load) { _ in exp.fulfill() }
        sut = nil
        loadSpy.complete(with: [])
        
        wait(for: [exp], timeout: 0.1)
    }
    
    func test_load_shouldDeliverEmptyOnLoadEmptySuccess() {
        
        let (sut, loadSpy, _) = makeSUT()
        
        expect(sut, with: .load, toDeliver: .loaded([])) {
            
            loadSpy.complete(with: [])
        }
    }
    
    func test_load_shouldDeliverOneOnLoadSuccessWithOne() {
        
        let latest = makeElement()
        let (sut, loadSpy, _) = makeSUT()
        
        expect(sut, with: .load, toDeliver: .loaded([latest])) {
            
            loadSpy.complete(with: [latest])
        }
    }
    
    func test_load_shouldDeliverTwoOnLoadSuccessWithTwo() {
        
        let (latest1, latest2) = (makeElement(), makeElement())
        let (sut, loadSpy, _) = makeSUT()
        
        expect(sut, with: .load, toDeliver: .loaded([latest1, latest2])) {
            
            loadSpy.complete(with: [latest1, latest2])
        }
    }
    
    // MARK: - reload
    
    func test_reload_shouldCallLoad() {
        
        let (sut, _, reloadSpy) = makeSUT()
        
        sut.handleEffect(.reload) { _ in }
        
        XCTAssertEqual(reloadSpy.callCount, 1)
    }
    
    func test_reload_shouldPassNotifyToReload() {
        
        let id = anyMessage()
        let (sut, _, reloadSpy) = makeSUT()
        var receivedEvents = [SUT.Event]()
        
        sut.handleEffect(.reload) { receivedEvents.append($0) }
        reloadSpy.payloads.first?(.update(state: .completed, forID: id))
        
        XCTAssertNoDiff(receivedEvents, [.update(state: .completed, forID: id)])
    }
    
    func test_reload_shouldNotDeliverResultOnInstanceDeallocation() throws {
        
        var sut: SUT?
        let reloadSpy: LoadSpy
        (sut, _, reloadSpy) = makeSUT()
        let exp = expectation(description: "completion should not be called")
        exp.isInverted = true
        
        sut?.handleEffect(.reload) { _ in exp.fulfill() }
        sut = nil
        reloadSpy.complete(with: [])
        
        wait(for: [exp], timeout: 0.1)
    }
    
    func test_reload_shouldDeliverEmptyOnLoadEmptySuccess() {
        
        let (sut, _, reloadSpy) = makeSUT()
        
        expect(sut, with: .reload, toDeliver: .loaded([])) {
            
            reloadSpy.complete(with: [])
        }
    }
    
    func test_reload_shouldDeliverOneOnLoadSuccessWithOne() {
        
        let latest = makeElement()
        let (sut, _, reloadSpy) = makeSUT()
        
        expect(sut, with: .reload, toDeliver: .loaded([latest])) {
            
            reloadSpy.complete(with: [latest])
        }
    }
    
    func test_reload_shouldDeliverTwoOnLoadSuccessWithTwo() {
        
        let (latest1, latest2) = (makeElement(), makeElement())
        let (sut, _, reloadSpy) = makeSUT()
        
        expect(sut, with: .reload, toDeliver: .loaded([latest1, latest2])) {
            
            reloadSpy.complete(with: [latest1, latest2])
        }
    }
    
    // MARK: - Helpers
    
    private typealias SUT = Domain.EffectHandler
    private typealias LoadSpy = Spy<(Event) -> Void, [Element]?>
    
    private func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        loadSpy: LoadSpy,
        reloadSpy: LoadSpy
    ) {
        let loadSpy = LoadSpy()
        let reloadSpy = LoadSpy()
        let sut = SUT(
            load: loadSpy.process,
            reload: reloadSpy.process
        )
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(loadSpy, file: file, line: line)
        
        return (sut, loadSpy, reloadSpy)
    }
    
    private func expect(
        _ sut: SUT,
        with effect: SUT.Effect,
        toDeliver expectedEvents: SUT.Event...,
        on action: @escaping () -> Void,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let exp = expectation(description: "wait for completion")
        exp.expectedFulfillmentCount = expectedEvents.count
        var events = [SUT.Event]()
        
        sut.handleEffect(effect) {
            
            events.append($0)
            exp.fulfill()
        }
        
        action()
        
        XCTAssertNoDiff(events, expectedEvents, file: file, line: line)
        
        wait(for: [exp], timeout: 1)
    }
}
