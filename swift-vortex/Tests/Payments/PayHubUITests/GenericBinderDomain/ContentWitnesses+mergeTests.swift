//
//  ContentWitnesses+mergeTests.swift
//
//
//  Created by Igor Malyarov on 12.11.2024.
//

import Combine
import PayHubUI
import XCTest

final class ContentWitnesses_mergeTests: XCTestCase {
    
    func test_emitting_emitsExpectedValue() {
        
        let content = 42
        let sut = makeSUT()
        
        let spy = ValueSpy(sut.emitting(content))
        
        XCTAssertEqual(spy.values, ["\(content)"])
    }
    
    func test_receiving_executesAction() {
        
        let content = 42
        let callSpy = CallSpy<Void, Void>(stubs: [()])
        let sut = makeSUT(receivingAction: callSpy.call)
        
        let action = sut.dismissing(content)
        action()
        
        XCTAssertEqual(callSpy.callCount, 1)
    }
    
    func test_merge_combinesEmittingFunctions() {
        
        let content = 42
        let sut1 = makeSUT(emittingValue: "First: \(content)")
        let sut2 = makeSUT(emittingValue: "Second: \(content)")
        
        var sut = sut1
        sut.merge(with: sut2)
        
        let spy = ValueSpy(sut.emitting(content))
        
        XCTAssertEqual(spy.values, ["First: 42", "Second: 42"])
    }
    
    func test_merge_combinesReceivingFunctions() {
        
        let callSpy1 = CallSpy<Void, Void>(stubs: [()])
        let sut1 = makeSUT(receivingAction: callSpy1.call)
        
        let callSpy2 = CallSpy<Void, Void>(stubs: [()])
        let sut2 = makeSUT(receivingAction: callSpy2.call)
        
        var sut = sut1
        sut.merge(with: sut2)
        
        let action = sut.dismissing(42)
        action()
        
        XCTAssertEqual(callSpy1.callCount, 1)
        XCTAssertEqual(callSpy2.callCount, 1)
    }
    
    // MARK: - Helpers
    
    typealias Witnesses = ContentWitnesses<Int, String>
    
    private func makeSUT(
        emittingValue: String? = nil,
        receivingAction: (() -> Void)? = nil
    ) -> Witnesses {
        
        let emitting: Witnesses.Emitting = { content in
            
            let value = emittingValue ?? "\(content)"
            return Just(value).eraseToAnyPublisher()
        }
        
        let receiving: Witnesses.Dismissing = { _ in
            
            receivingAction ?? {}
        }
        
        return Witnesses(emitting: emitting, dismissing: receiving)
    }
}
