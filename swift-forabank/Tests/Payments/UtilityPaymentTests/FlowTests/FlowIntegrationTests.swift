//
//  FlowIntegrationTests.swift
//
//
//  Created by Igor Malyarov on 14.03.2024.
//

import RxViewModel
import UtilityPayment
import XCTest

enum UpdateFlowEvent {
    
    case initiate
}

extension UpdateFlowEvent: Equatable {}

enum UpdateFlowEffect {
    
    case initiate
}

extension UpdateFlowEffect: Equatable {}

final class DestinationUpdater {
    
}

extension DestinationUpdater {
    
    func update(
        _ state: State,
        _ event: Event
    ) -> (Destination<LastPayment, Operator>?, Effect?) {
        
        switch event {
        case .initiate:
            return (nil, .initiate)
        }
    }
}

extension DestinationUpdater {
    
    typealias State = Flow<Destination<LastPayment, Operator>>
    typealias Event = UpdateFlowEvent
    typealias Effect = UpdateFlowEffect
}

final class StackStacker {
    
}

extension StackStacker {
    
    func push(
        _ state: State,
        _ event: Event
    ) -> (Destination<LastPayment, Operator>, Effect?) {
        
        fatalError()
    }
}

extension StackStacker {
    
    typealias State = Flow<Destination<LastPayment, Operator>>
    typealias Event = PushEvent
    typealias Effect = PushEffect
}

final class DestinationUpdaterTests: XCTestCase {
    
    func test_initiate_shouldDeliverNilDestinationOnEmptyState() {
        
        let emptyState = State()
        let sut = makeSUT()
        
        let (destination, _) = sut.update(emptyState, .initiate)
        
        XCTAssertNil(destination)
    }
    
    func test_initiate_shouldDeliverEffectOnEmptyState() {
        
        let emptyState = State()
        let sut = makeSUT()
        
        let (_, effect) = sut.update(emptyState, .initiate)
        
        XCTAssertNoDiff(effect, .initiate)
    }
    
    func test_initiate_shouldDeliverNilDestinationOnNonEmptyState() {
        
        let nonEmptyState = State(stack: .init(.services))
        let sut = makeSUT()
        
        let (destination, _) = sut.update(nonEmptyState, .initiate)
        
        XCTAssertNil(destination)
    }
    
    func test_initiate_shouldDeliverEffectOnNonEmptyState() {
        
        let nonEmptyState = State(stack: .init(.services))
        let sut = makeSUT()
        
        let (_, effect) = sut.update(nonEmptyState, .initiate)
        
        XCTAssertNoDiff(effect, .initiate)
    }
    
    // MARK: - Helpers
    
    private typealias SUT = DestinationUpdater
    
    private typealias State = SUT.State
    private typealias Event = SUT.Event
    private typealias Effect = SUT.Effect
    
    private func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> SUT {
        
        let sut = SUT()
        
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return sut
    }
}

final class FlowIntegrationTests: XCTestCase {
    
    func test_init_shouldNotCallCollaborators() {
        
        let (_,_, pushSpy, updateSpy) = makeSUT()
        
        XCTAssertEqual(pushSpy.callCount, 0)
        XCTAssertEqual(updateSpy.callCount, 0)
    }
    
    func test_flow() {
        
        let (sut, spy, pushSpy, updateSpy) = makeSUT()
        
        sut.event(.update(.initiate))
        updateSpy.complete(with: .initiate)
    }
    
    // MARK: - Helpers
    
    private typealias SUT = RxViewModel<State, Event, Effect>
    
    private typealias State = Flow<Destination<LastPayment, Operator>>
    private typealias Event = PushUpdateFlowEvent<PushEvent, UpdateFlowEvent>
    private typealias Effect = PushUpdateFlowEffect<PushEffect, UpdateFlowEffect>
    
    private typealias Reducer = PushUpdateFlowReducer<Destination<LastPayment, Operator>, PushEvent, UpdateFlowEvent, PushEffect, UpdateFlowEffect>
    private typealias EffectHandler = PushUpdateFlowEffectHandler<PushEvent, UpdateFlowEvent, PushEffect, UpdateFlowEffect>
    
    private typealias StateSpy = ValueSpy<State>
    private typealias PushSpy = Spy<PushEffect, PushEvent>
    private typealias UpdateSpy = Spy<UpdateFlowEffect, UpdateFlowEvent>
    
    private func makeSUT(
        initialState: State = .init(),
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        spy: StateSpy,
        pushSpy: PushSpy,
        updateSpy: UpdateSpy
    ) {
        let stacker = StackStacker()
        let updater = DestinationUpdater()
        
        let reducer = Reducer(
            push: stacker.push,
            update: updater.update
        )
        
        let pushSpy = PushSpy()
        let updateSpy = UpdateSpy()
        
        let effectHandler = EffectHandler(
            push: pushSpy.process(_:completion:),
            update: updateSpy.process(_:completion:)
        )
        
        let sut = SUT(
            initialState: initialState,
            reduce: reducer.reduce(_:_:),
            handleEffect: effectHandler.handleEffect(_:_:),
            scheduler: .immediate
        )
        
        let spy = StateSpy(sut.$state)
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(spy, file: file, line: line)
        trackForMemoryLeaks(pushSpy, file: file, line: line)
        trackForMemoryLeaks(updateSpy, file: file, line: line)
        
        return (sut, spy, pushSpy, updateSpy)
    }
    
    private func assert(
        _ spy: StateSpy,
        _ initialState: State,
        _ updates: ((inout State) -> Void)...,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        var state = initialState
        var values = [State]()
        
        for update in updates {
            
            update(&state)
            values.append(state)
        }
        
        XCTAssertNoDiff(spy.values, values, file: file, line: line)
    }
}
