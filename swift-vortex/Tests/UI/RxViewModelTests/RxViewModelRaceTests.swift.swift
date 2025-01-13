//
//  RxViewModelRaceTests.swift
//
//
//  Created by Igor Malyarov on 03.11.2024.
//

import Combine
import CombineSchedulers
import RxViewModel
import XCTest

final class RxViewModelRaceTests: XCTestCase {
    
    func test_init_shouldSetInitialValue() {
        
        let value = anyMessage()
        let (_, stateSpy, _, scheduler) = makeSUT(initialValue: value)
        
        scheduler.advance()
        
        XCTAssertNoDiff(stateSpy.values, [value])
    }
    
    func test_shouldNotOverwriteStateOnSuccessiveEventsWithoutEffect() {
        
        let (sut, stateSpy, _, scheduler) = makeSUT(initialValue: "")
        
        sut.event(.append("a"))
        
        XCTAssertNoDiff(stateSpy.values, [""])
        
        sut.event(.append("b"))
        
        XCTAssertNoDiff(stateSpy.values, [""])
        
        scheduler.advance()
        
        XCTAssertNoDiff(stateSpy.values, ["", "a", "ab"])
    }
    
    func test_shouldUpdateStateOnSeparateEventsWithoutEffect() {
        
        let (sut, stateSpy, _, scheduler) = makeSUT(initialValue: "")
        
        sut.event(.append("a"))
        scheduler.advance()
        
        XCTAssertNoDiff(stateSpy.values, ["", "a" ])
        
        sut.event(.append("b"))
        
        XCTAssertNoDiff(stateSpy.values, ["", "a"])
        
        scheduler.advance()
        
        XCTAssertNoDiff(stateSpy.values, ["", "a", "ab"])
    }
    
    func test_shouldChangeStateOnDuplicateEvents() {
        
        let (sut, stateSpy, _, scheduler) = makeSUT(initialValue: "")
        
        sut.event(.append("a"))
        scheduler.advance()
        
        XCTAssertNoDiff(stateSpy.values, ["", "a" ])
        
        sut.event(.append("a"))
        
        XCTAssertNoDiff(stateSpy.values, ["", "a"])
        
        scheduler.advance()
        
        XCTAssertNoDiff(stateSpy.values, ["", "a", "aa"])
    }
    
    func test_shouldCallEffectHandlerWithEffect() {
        
        let (sut, _, effectSpy, scheduler) = makeSUT(initialValue: "")
        
        sut.event(.setValue(1))
        sut.event(.setValue(2))
        
        scheduler.advance()
        
        XCTAssertNoDiff(effectSpy.payloads, [.setValue(1), .setValue(2)])
    }
    
    func test_shouldUpdateValuesWithEffect() {
        
        let (sut, stateSpy, effectSpy, scheduler) = makeSUT(initialValue: "")
        
        sut.event(.setValue(1))
        scheduler.advance()
        
        effectSpy.complete(with: .append("A"))
        
        sut.event(.setValue(2))
        scheduler.advance()
        
        XCTAssertNoDiff(stateSpy.values, ["", "-", "-A", "-A-"])
        
        effectSpy.complete(with: .append("B"), at: 1)
        
        XCTAssertNoDiff(stateSpy.values, ["", "-", "-A", "-A-"])
        
        scheduler.advance()
        
        XCTAssertNoDiff(stateSpy.values, ["", "-", "-A", "-A-",  "-A-B"])
    }
    
    func test_shouldUpdateValueWithEffectAfterNextSyncEvent() {
        
        let (sut, stateSpy, effectSpy, scheduler) = makeSUT(initialValue: "")
        
        sut.event(.setValue(1))
        sut.event(.append("B"))
        
        scheduler.advance()
        
        XCTAssertNoDiff(stateSpy.values, ["", "-", "-B"])
        
        effectSpy.complete(with: .append("A"))
        
        XCTAssertNoDiff(stateSpy.values, ["", "-", "-B"])
        
        scheduler.advance()
        
        XCTAssertNoDiff(stateSpy.values, ["", "-", "-B", "-BA"])
    }
    
    func test_shouldUsePredicateToSkipStateUpdate() {
        
        let (sut, stateSpy, _, scheduler) = makeSUT(
            initialValue: "A",
            predicate: { $0.value.prefix(3) == $1.value.prefix(3) }
        )
        
        sut.event(.append("BC"))
        scheduler.advance()
        
        XCTAssertNoDiff(stateSpy.values, ["A", "ABC"])
        
        sut.event(.append("D"))
        scheduler.advance()
        
        XCTAssertNoDiff(stateSpy.values, ["A", "ABC"], "Expected no new state value due to predicate.")
    }
    
    func test_shouldUsePredicateToAllowStateUpdate() {
        
        let (sut, stateSpy, _, scheduler) = makeSUT(
            initialValue: "Start",
            predicate: { _,_ in false }
        )
        
        sut.event(.append("A"))
        scheduler.advance()
        
        XCTAssertNoDiff(stateSpy.values, ["Start", "StartA"])
    }
    
    func test_shouldMaintainPerformanceUnderHighVolumeEvents() {
        
        let (sut, stateSpy, _, scheduler) = makeSUT(initialValue: "")
        
        for i in 0..<1000 {
            
            sut.event(.append("\(i)"))
        }
        
        scheduler.advance()
        
        XCTAssertNoDiff(
            stateSpy.values.last,
            (0..<1000).map(String.init).joined()
        )
    }
    
    func test_shouldNotDeliverEffectEventsOnInstanceDeallocation() {
        
        var sut: SUT?
        let stateSpy:  StateSpy
        let effectSpy: EffectSpy
        let scheduler: TestSchedulerOf<DispatchQueue>
        (sut, stateSpy, effectSpy, scheduler) = makeSUT(initialValue: "")
        
        sut?.event(.setValue(1))
        scheduler.advance()
        
        sut = nil
        effectSpy.complete(with: .append(anyMessage()))
        scheduler.advance()
        
        XCTAssertNoDiff(stateSpy.values, ["", "-"], "No further events should be processed after deallocation")
    }
    
    // MARK: - Helpers
    
    private typealias SUT = RxViewModel<State, Event, Effect>
    private typealias StateSpy = ValueSpy<String>
    private typealias EffectSpy = Spy<Effect, Event>
    
    private func makeSUT(
        initialValue: String = anyMessage(),
        predicate: @escaping (State, State) -> Bool = { _, _ in false },
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        stateSpy: StateSpy,
        effectSpy: EffectSpy,
        scheduler: TestSchedulerOf<DispatchQueue>
    ) {
        let effectSpy = EffectSpy()
        let scheduler = DispatchQueue.test
        let sut = SUT(
            initialState: makeState(initialValue),
            reduce: {
                
                switch $1 {
                case let .append(value):
                    return (.init(value: $0.value + value), nil)
                    
                case let .setValue(value):
                    return (.init(value: $0.value + "-"), .setValue(value))
                }
            },
            handleEffect: effectSpy.process,
            predicate: predicate,
            scheduler: scheduler.eraseToAnyScheduler()
        )
        let stateSpy = StateSpy(sut.$state.map(\.value))
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(stateSpy, file: file, line: line)
        trackForMemoryLeaks(effectSpy, file: file, line: line)
        trackForMemoryLeaks(scheduler, file: file, line: line)
        
        return (sut, stateSpy, effectSpy, scheduler)
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
        case setValue(Int)
    }
    
    private enum Effect: Equatable {
        
        case setValue(Int)
    }
}
