//
//  PushUpdateFlowReducerTests.swift
//  
//
//  Created by Igor Malyarov on 14.03.2024.
//

import UtilityPayment
import XCTest

final class PushUpdateFlowReducerTests: XCTestCase {
    
    // MARK: - push
    
    func test_pushEvent_shouldCallPushWithStateAndEvent() {
        
        let state = State()
        let event = PushEvent.push
        let (sut, pushSpy, _) = makeSUT()
        
        _ = sut.reduce(state, .push(event))
        
        XCTAssertNoDiff(pushSpy.payloads.map(\.0), [state])
        XCTAssertNoDiff(pushSpy.payloads.map(\.1), [event])
    }
    
    func test_pushEvent_shouldDeliverPushStateOnEmpty() {
        
        let empty = State()
        let destination = makePrepaymentOptions()
        let (sut, _,_) = makeSUT(pushStub: (destination, nil))
        
        assertState(sut: sut, .push(.push), on: empty) {
            
            $0.current = destination
        }
    }
    
    func test_pushEvent_shouldDeliverPushStateOnTopOfNonEmpty() {
        
        let nonEmpty = State(stack: .init(makePrepaymentOptions()))
        let destination = makePrepaymentOptions()
        let (sut, _,_) = makeSUT(pushStub: (destination, nil))
        
        assertState(sut: sut, .push(.push), on: nonEmpty) {
            
            $0.push(destination)
        }
    }
    
    func test_pushEvent_shouldDeliverPushEffect() {
        
        let effect = PushEffect.push
        let (sut, _,_) = makeSUT(pushStub: (.services([makeService(), makeService()]), effect))
        
        assert(sut: sut, .push(.push), on: .init(), effect: .push(effect))
    }
    
    func test_pushEvent_shouldDeliverPushEffect_nil() {
        
        let (sut, _,_) = makeSUT(pushStub: (.services([makeService(), makeService()]), nil))
        
        assert(sut: sut, .push(.push), on: .init(), effect: nil)
    }
    
    // MARK: - update
    
    func test_updateEvent_shouldCallUpdateWithStateAndEvent() {
        
        let state = State()
        let event = UpdateEvent.update
        let (sut, _, updateSpy) = makeSUT()
        
        _ = sut.reduce(state, .update(event))
        
        XCTAssertNoDiff(updateSpy.payloads.map(\.0), [state])
        XCTAssertNoDiff(updateSpy.payloads.map(\.1), [event])
    }
    
    func test_updateEvent_shouldDeliverUpdateStateOnEmpty() {
        
        let empty = State()
        let destination = makePrepaymentOptions()
        let (sut, _,_) = makeSUT(updateStub: (destination, nil))
        
        assertState(sut: sut, .update(.update), on: empty) {
            
            $0.current = destination
        }
    }
    
    func test_updateEvent_shouldChangeStateToUpdatedOnNonEmpty() {
        
        let nonEmpty = State(stack: .init(makePrepaymentOptions()))
        let destination = makePrepaymentOptions()
        let (sut, _,_) = makeSUT(updateStub: (destination, nil))
        
        assertState(sut: sut, .update(.update), on: nonEmpty) {
            
            $0.current = destination
        }
    }
    
    func test_updateEvent_shouldDeliverUpdateEffect() {
        
        let effect = UpdateEffect.update
        let (sut, _,_) = makeSUT(updateStub: (.services([makeService(), makeService()]), effect))
        
        assert(sut: sut, .update(.update), on: .init(), effect: .update(effect))
    }
    
    func test_updateEvent_shouldDeliverUpdateEffect_nil() {
        
        let (sut, _,_) = makeSUT(updateStub: (.services([makeService(), makeService()]), nil))
        
        assert(sut: sut, .update(.update), on: .init(), effect: nil)
    }
    
    // MARK: - Helpers
    
    private typealias SUT = PushUpdateFlowReducer<Destination, PushEvent, UpdateEvent, PushEffect, UpdateEffect>
    
    private typealias State = UtilityFlow
    private typealias Event = PushUpdateFlowEvent<PushEvent, UpdateEvent>
    private typealias Effect = PushUpdateFlowEffect<PushEffect, UpdateEffect>
    
    private typealias PushSpy = CallSpy<(Flow<Destination>, PushEvent)>
    private typealias UpdateSpy = CallSpy<(Flow<Destination>, UpdateEvent)>
    
    private func makeSUT(
        pushStub: (Destination, PushEffect?) = (.services([makeService(), makeService()]), nil),
        updateStub: (Destination, UpdateEffect?) = (.services([makeService(), makeService()]), nil),
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        pushSpy: PushSpy,
        updateSpy: UpdateSpy
    ) {
        let pushSpy = PushSpy()
        let updateSpy = UpdateSpy()
        
        let sut = SUT(
            push: {
                
                pushSpy.call(payload: ($0, $1))
                return pushStub
            },
            update: {
                
                updateSpy.call(payload: ($0, $1))
                return updateStub
            }
        )
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(pushSpy, file: file, line: line)
        trackForMemoryLeaks(updateSpy, file: file, line: line)
        
        return (sut, pushSpy, updateSpy)
    }
    
    private typealias UpdateStateToExpected<State> = (_ state: inout State) -> Void
    
    private func assertState(
        sut: SUT,
        _ event: Event,
        on state: State,
        updateStateToExpected: UpdateStateToExpected<State>? = nil,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        var expectedState = state
        updateStateToExpected?(&expectedState)
        
        let (receivedState, _) = sut.reduce(state, event)
        
        XCTAssertNoDiff(
            receivedState,
            expectedState,
            "\nExpected \(expectedState), but got \(receivedState) instead.",
            file: file, line: line
        )
    }
    
    private func assert(
        sut: SUT,
        _ event: Event,
        on state: State,
        effect expectedEffect: Effect?,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let (_, receivedEffect) = sut.reduce(state, event)
        
        XCTAssertNoDiff(
            receivedEffect,
            expectedEffect,
            "\nExpected \(String(describing: expectedEffect)), but got \(String(describing: receivedEffect)) instead.",
            file: file, line: line
        )
    }
}
