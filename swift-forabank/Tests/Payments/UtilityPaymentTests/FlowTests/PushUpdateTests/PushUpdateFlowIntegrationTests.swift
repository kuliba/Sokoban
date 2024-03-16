//
//  PushUpdateFlowIntegrationTests.swift
//
//
//  Created by Igor Malyarov on 14.03.2024.
//

import RxViewModel
import UtilityPayment
import XCTest

final class PushUpdateFlowIntegrationTests: XCTestCase {
    
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
    
    private typealias State = UtilityFlow
    private typealias Event = PushUpdateFlowEvent<PushEvent, UpdateFlowEvent>
    private typealias Effect = PushUpdateFlowEffect<PushEffect, UpdateFlowEffect>
    
    private typealias Reducer = PushUpdateFlowReducer<Destination, PushEvent, UpdateFlowEvent, PushEffect, UpdateFlowEffect>
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
