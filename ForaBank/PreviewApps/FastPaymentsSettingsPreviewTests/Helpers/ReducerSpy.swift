//
//  ReducerSpy.swift
//
//
//  Created by Igor Malyarov on 14.01.2024.
//

final class ReducerSpy<State, Event> {
    
    typealias Message = (state: State, event: Event, completion: (State) -> Void)
    
    private(set) var messages = [Message]()
    
    var callCount: Int { messages.count }
    var states: [State] { messages.map(\.state) }
    var events: [Event] { messages.map(\.event) }
    
    func reduce(
        _ state: State,
        _ event: Event,
        _ completion: @escaping (State) -> Void
    ) {
        messages.append((state, event, completion))
    }
    
    func complete(
        with state: State,
        at index: Int = 0
    ) {
        messages[index].completion(state)
    }
}
