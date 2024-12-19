//
//  LoadablePickerTests.swift
//
//
//  Created by Igor Malyarov on 20.08.2024.
//

import PayHub
import XCTest

class LoadablePickerTests: XCTestCase {
    
    // MARK: - Helpers
    
    typealias ID = UUID
    typealias Reducer = LoadablePickerReducer<ID, Element>
    typealias EffectHandler = LoadablePickerEffectHandler<Element>
    typealias LoadSpy = Spy<Void, [Element]?>

    func makeItem(
        id: ID = .init(),
        _ element: Element? = nil
    ) -> Reducer.State.Item {
        
        return .element(.init(id: id, element: element ?? makeElement()))
    }
    
    func makeID() -> ID {
        
        return .init()
    }
    
    func makePlaceholderID() -> ID {
        
        return .init()
    }
    
    struct Element: Equatable {
        
        let value: String
    }
    
    func makeElement(
        _ value: String = anyMessage()
    ) -> Element {
        
        return .init(value: value)
    }
    
    func makeEffectHandler(
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: EffectHandler,
        loadSpy: LoadSpy,
        reloadSpy: LoadSpy
    ) {
        let loadSpy = LoadSpy()
        let reloadSpy = LoadSpy()
        let sut = EffectHandler(
            microServices: .init(
                load: loadSpy.process,
                reload: reloadSpy.process
            )
        )
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(loadSpy, file: file, line: line)
        
        return (sut, loadSpy, reloadSpy)
    }
    
    func expect(
        _ sut: EffectHandler,
        with effect: EffectHandler.Effect,
        toDeliver expectedEvents: EffectHandler.Event...,
        on action: @escaping () -> Void,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let exp = expectation(description: "wait for completion")
        exp.expectedFulfillmentCount = expectedEvents.count
        var events = [EffectHandler.Event]()
        
        sut.handleEffect(effect) {
            
            events.append($0)
            exp.fulfill()
        }
        
        action()
        
        XCTAssertNoDiff(events, expectedEvents, file: file, line: line)
        
        wait(for: [exp], timeout: 1)
    }
}
