//
//  FlowTests.swift
//
//
//  Created by Igor Malyarov on 14.03.2024.
//

import ForaTools

struct Flow<Destination> {
    
    private(set) var stack: Stack<Destination>
    
    init(stack: Stack<Destination> = .init([])) {
        
        self.stack = stack
    }
}

extension Flow {
    
    var current: Destination? {
        
        get { stack.top }
        set { stack.top = newValue }
    }
    
    mutating func push(_ destination: Destination) {
        
        stack.push(destination)
    }
}

extension Flow: Equatable where Destination: Equatable {}

enum FlowEvent<PushEvent, UpdateEvent> {
    
    case push(PushEvent)
    case update(UpdateEvent)
}

extension FlowEvent: Equatable where PushEvent: Equatable, UpdateEvent: Equatable {}

enum FlowEffect<PushEffect, UpdateEffect> {
    
    case push(PushEffect)
    case update(UpdateEffect)
}

extension FlowEffect: Equatable where PushEffect: Equatable, UpdateEffect: Equatable {}

import RxViewModel
import XCTest

final class FlowIntegrationTests: XCTestCase {
    
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
        pushStub: (Destination, PushEffect?),
        updateStub: (Destination, UpdateEffect?),
        initialState: State = .init(),
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        spy: StateSpy,
        pushSpy: PushSpy,
        updateSpy: UpdateSpy
    ) {
        let reducer = Reducer(
            push: { _,_ in pushStub },
            update: { _,_ in updateStub }
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
            handleEffect: effectHandler.handleEffect(_:_:)
        )
        let spy = StateSpy(sut.$state)
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(spy, file: file, line: line)
        trackForMemoryLeaks(pushSpy, file: file, line: line)
        trackForMemoryLeaks(updateSpy, file: file, line: line)
        
        return (sut, spy, pushSpy, updateSpy)
    }
}
