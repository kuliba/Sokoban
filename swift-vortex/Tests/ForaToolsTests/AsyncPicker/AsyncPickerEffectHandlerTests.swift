//
//  AsyncPickerEffectHandlerTests.swift
//
//
//  Created by Igor Malyarov on 23.07.2024.
//

import ForaTools
import XCTest

final class AsyncPickerEffectHandlerTests: AsyncPickerTests {
    
    func test_init_shouldNotCallaCollaborators() {
        
        let (sut, loadSpy, selectSpy) = makeSUT()
        
        XCTAssertEqual(loadSpy.callCount, 0)
        XCTAssertEqual(selectSpy.callCount, 0)
        XCTAssertNotNil(sut)
    }
    
    // MARK: - load
    
    func test_load_shouldCallLoadWithPayload() {
        
        let payload = makePayload()
        let (sut, loadSpy, _) = makeSUT()
        
        sut.handleEffect(.load(payload)) { _ in }
        
        XCTAssertNoDiff(loadSpy.payloads, [payload])
    }
    
    func test_load_shouldDeliverEmptyLoadResult() {
        
        let (sut, loadSpy, _) = makeSUT()
        
        expect(sut, with: .load(makePayload()), toDeliver: .loaded([])) {
            
            loadSpy.complete(with: [])
        }
    }
    
    func test_load_shouldDeliverOneItemLoadResult() {
        
        let item = makeItem()
        let (sut, loadSpy, _) = makeSUT()
        
        expect(sut, with: .load(makePayload()), toDeliver: .loaded([item])) {
            
            loadSpy.complete(with: [item])
        }
    }
    
    func test_load_shouldDeliverTwoItemLoadResult() {
        
        let items = makeItems(count: 2)
        let (sut, loadSpy, _) = makeSUT()
        
        expect(sut, with: .load(makePayload()), toDeliver: .loaded(items)) {
            
            loadSpy.complete(with: items)
        }
    }
    
    // MARK: - select
    
    func test_select_shouldCallLoadWithPayload() {
        
        let (item, payload) = (makeItem(), makePayload())
        let (sut, _, selectSpy) = makeSUT()
        
        sut.handleEffect(.select(item, payload)) { _ in }
        
        XCTAssertNoDiff(selectSpy.payloads.map(\.0), [item])
        XCTAssertNoDiff(selectSpy.payloads.map(\.1), [payload])
    }
    
    func test_select_shouldDeliverEmptyLoadResult() {
        
        let response = makeResponse()
        let (sut, _, selectSpy) = makeSUT()
        
        expect(sut, with: .select(makeItem(), makePayload()), toDeliver: .response(response)) {
            
            selectSpy.complete(with: response)
        }
    }
    
    // MARK: - Helpers
    
    private typealias SUT = AsyncPickerEffectHandler<Payload, Item, Response>
    private typealias LoadSpy = Spy<Payload, [Item]>
    private typealias SelectSpy = Spy<(Item, Payload), Response>
    
    private func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        loadSpy: LoadSpy,
        selectSpy: SelectSpy
    ) {
        let loadSpy = LoadSpy()
        let selectSpy = SelectSpy()
        let sut = SUT(
            microServices: .init(
                load: loadSpy.process,
                select: { selectSpy.process(($0, $1), completion: $2) }
            )
        )
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(loadSpy, file: file, line: line)
        trackForMemoryLeaks(selectSpy, file: file, line: line)
        
        return (sut, loadSpy, selectSpy)
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
