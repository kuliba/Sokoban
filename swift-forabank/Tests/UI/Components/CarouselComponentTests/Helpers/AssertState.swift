//
//  AssertState.swift
//
//
//  Created by Disman Dmitry on 27.02.2024.
//

import RxViewModel

typealias UpdateStateToExpected<State> = (_ state: inout State) -> Void

func _assertState<State, Event, Effect>(
    _ sut: any Reducer<State, Event, Effect>,
    _ event: Event,
    on state: State,
    updateStateToExpected: UpdateStateToExpected<State>? = nil,
    file: StaticString = #file,
    line: UInt = #line
) where State: Equatable, Event: Equatable, Effect: Equatable {
    
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
