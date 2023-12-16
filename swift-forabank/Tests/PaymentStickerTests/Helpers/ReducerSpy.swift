//
//  ReducerSpy.swift
//
//
//  Created by Igor Malyarov on 08.12.2023.
//

final class ReducerSpy<State, Event> {
    
    private(set) var payloads = [(state: State, event: Event)]()
    private let stub: State
    
    var callCount: Int { payloads.count }
    var states: [State] { payloads.map(\.state) }
    var events: [Event] { payloads.map(\.event) }
    
    init(stub: State) {
        
        self.stub = stub
    }
    
    func reduce(
        state: State,
        event: Event
    ) -> State {
        
        payloads.append((state, event))
        
        return stub
    }
}
