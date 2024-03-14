//
//  FlowIntegrationTests.swift
//
//
//  Created by Igor Malyarov on 14.03.2024.
//

import RxViewModel
import UtilityPayment
import XCTest

final class FlowIntegrationTests: XCTestCase {
    
    func test_init_shouldNotCallCollaborators() {
        
        let (_,_, pushSpy, updateSpy) = makeSUT()
        
        XCTAssertEqual(pushSpy.callCount, 0)
        XCTAssertEqual(updateSpy.callCount, 0)
    }
    
    // MARK: - Helpers
    
    private typealias SUT = RxViewModel<State, Event, Effect>
    
    private typealias State = Flow<Destination>
    private typealias Event = FlowEvent<PushEvent, UpdateEvent>
    private typealias Effect = FlowEffect<PushEffect, UpdateEffect>
    
    private typealias Reducer = FlowReducer<Destination, PushEvent, UpdateEvent, PushEffect, UpdateEffect>
    private typealias EffectHandler = FlowEffectHandler<PushEvent, UpdateEvent, PushEffect, UpdateEffect>
    
    private typealias StateSpy = ValueSpy<State>
    private typealias PushSpy = Spy<PushEffect, PushEvent>
    private typealias UpdateSpy = Spy<UpdateEffect, UpdateEvent>
    
    private func makeSUT(
        initialState: State = .init(),
        push: @escaping Reducer.Push = { _,_ in (.services, nil) },
        update: @escaping Reducer.Update = { _,_ in (.services, nil) },
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        spy: StateSpy,
        pushSpy: PushSpy,
        updateSpy: UpdateSpy
    ) {
        let reducer = Reducer(push: push, update: update)
        
        let pushSpy = PushSpy()
        let updateSpy = UpdateSpy()
        
        let effectHandler = EffectHandler(
            push: pushSpy.process(_:completion:),
            update: updateSpy.process(_:completion:)
        )
        
        let sut = SUT(
            initialState: initialState,
            reduce: reducer.reduce(_:_:),
            handleEffect: effectHandler.handleEffect(_:_:)
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
