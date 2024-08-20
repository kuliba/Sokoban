//
//  LoadablePickerEffectHandlerTests.swift
//  
//
//  Created by Igor Malyarov on 20.08.2024.
//

import PayHub
import XCTest

final class LoadablePickerEffectHandlerTests: LoadablePickerTests {
    
    // MARK: - init
    
    func test_init_shouldNotCallCollaborator() {
        
        let (sut, loadSpy) = makeSUT()
        
        XCTAssertEqual(loadSpy.callCount, 0)
        XCTAssertNotNil(sut)
    }
    
    // MARK: - load
    
    func test_load_shouldCallLoad() {
        
        let (sut, loadSpy) = makeSUT()
        
        sut.handleEffect(.load) { _ in }
        
        XCTAssertEqual(loadSpy.callCount, 1)
    }
    
    func test_load_shouldNotDeliverResultOnInstanceDeallocation() throws {
        
        var sut: SUT?
        let loadSpy: LoadSpy
        (sut, loadSpy) = makeSUT()
        let exp = expectation(description: "completion should not be called")
        exp.isInverted = true
        
        sut?.handleEffect(.load) { _ in exp.fulfill() }
        sut = nil
        loadSpy.complete(with: [])
        
        wait(for: [exp], timeout: 0.1)
    }
    
    func test_load_shouldDeliverEmptyOnLoadEmptySuccess() {
        
        let (sut, loadPay) = makeSUT()
        
        expect(sut, with: .load, toDeliver: .loaded([])) {
            
            loadPay.complete(with: [])
        }
    }
    
    func test_load_shouldDeliverOneOnLoadSuccessWithOne() {
        
        let latest = makeElement()
        let (sut, loadPay) = makeSUT()
        
        expect(sut, with: .load, toDeliver: .loaded([latest])) {
            
            loadPay.complete(with: [latest])
        }
    }
    
    func test_load_shouldDeliverTwoOnLoadSuccessWithTwo() {
        
        let (latest1, latest2) = (makeElement(), makeElement())
        let (sut, loadPay) = makeSUT()
        
        expect(sut, with: .load, toDeliver: .loaded([latest1, latest2])) {
            
            loadPay.complete(with: [latest1, latest2])
        }
    }
    
    // MARK: - Helpers
    
    private typealias SUT = LoadablePickerEffectHandler<Element>
    private typealias LoadSpy = Spy<Void, [Element]>
    
    private func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        loadSpy: LoadSpy
    ) {
        let loadSpy = LoadSpy()
        let sut = SUT(
            microServices: .init(
                load: loadSpy.process
            )
        )
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(loadSpy, file: file, line: line)
        
        return (sut, loadSpy)
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
