//
//  RxViewModelImmediateRaceTests.swift
//
//
//  Created by Igor Malyarov on 03.11.2024.
//

import Combine
import CombineSchedulers
import RxViewModel
import XCTest

final class RxViewModelImmediateRaceTests: XCTestCase {
    
    func test_eventAppend_updatesStateWithConcatenatedValues() {
        
        let (sut, stateSpy) = makeSUT("")
        XCTAssertNoDiff(stateSpy.values, [
            .init(value: ""),
        ])
        
        sut.event(.append("a"))
        
        XCTAssertNoDiff(stateSpy.values, [
            .init(value: ""),
            .init(value: "a"),
        ])
        
        sut.event(.append("b"))
        
        XCTAssertNoDiff(stateSpy.values, [
            .init(value: ""),
            .init(value: "a"),
            .init(value: "ab"),
        ])
    }
    
    func test_eventSetValue_replacesStateValue() {
        
        let (sut, stateSpy) = makeSUT("")
        XCTAssertNoDiff(stateSpy.values, [
            .init(value: ""),
        ])
        
        sut.event(.setValue("a"))
        sut.event(.setValue("b"))
        
        XCTAssertNoDiff(stateSpy.values, [
            .init(value: ""),
            .init(value: "a"),
            .init(value: "b"),
        ])
    }
    
    // MARK: - Helpers
    
    private typealias SUT = RxViewModel<State, Event, Never>
    private typealias StateSpy = ValueSpy<State>
    
    private func makeSUT(
        _ initialValue: String = anyMessage(),
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        stateSpy: StateSpy
    ) {
        let sut = SUT(
            initialState: makeState(initialValue),
            reduce: {
                
                switch $1 {
                case let .append(value):
                    return (.init(value: $0.value + value), nil)
                    
                case let .setValue(value):
                    return (.init(value: value), nil)
                }
            },
            handleEffect: { _,_ in },
            scheduler: .immediate
        )
        let stateSpy = StateSpy(sut.$state)
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(stateSpy, file: file, line: line)
        
        return (sut, stateSpy)
    }
    
    private struct State: Equatable {
        
        let value: String
    }
    
    private func makeState(
        _ value: String = anyMessage()
    ) -> State {
        
        return .init(value: value)
    }
    
    private enum Event: Equatable {
        
        case append(String)
        case setValue(String)
    }
}
