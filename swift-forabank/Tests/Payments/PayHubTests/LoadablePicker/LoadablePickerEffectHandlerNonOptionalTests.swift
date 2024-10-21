//
//  LoadablePickerEffectHandlerNonOptionalTests.swift
//
//
//  Created by Igor Malyarov on 20.08.2024.
//

import PayHub
import XCTest

final class LoadablePickerEffectHandlerNonOptionalTests: LoadablePickerTests {
    
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
    
    // MARK: - Helpers
    
    private typealias SUT = EffectHandler
    
    private func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        loadSpy: LoadSpy,
        reloadSpy: LoadSpy
    ) {
        makeEffectHandler(file: #file, line: #line)
    }
}
