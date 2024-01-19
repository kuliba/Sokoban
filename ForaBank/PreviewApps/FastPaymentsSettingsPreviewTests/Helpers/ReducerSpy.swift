//
//  ReducerSpy.swift
//
//
//  Created by Igor Malyarov on 14.01.2024.
//

final class ReducerSpy<State, Event, Effect> {
    
    typealias Message = (state: State, event: Event)
    typealias Stub = (state: State, effect: Effect?)
    
    private let stub: Stub
    
    init(stub: Stub) {
        
        self.stub = stub
    }
    
    private(set) var messages = [Message]()
    
    var callCount: Int { messages.count }
    var states: [State] { messages.map(\.state) }
    var events: [Event] { messages.map(\.event) }
    
    func reduce(
        _ state: State,
        _ event: Event
    ) -> (State, Effect?) {
        
        messages.append((state, event))
        
        return stub
    }
}
