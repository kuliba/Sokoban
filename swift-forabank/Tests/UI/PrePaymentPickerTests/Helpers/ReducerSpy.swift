//
//  ReducerSpy.swift
//
//
//  Created by Igor Malyarov on 08.12.2023.
//

final class ReducerSpy<State, Event, Effect> {
    
    typealias Stub = (State, Effect?)
    
    private(set) var payloads = [(state: State, event: Event)]()
    private let stub: Stub
    
    var callCount: Int { payloads.count }
    var states: [State] { payloads.map(\.state) }
    var events: [Event] { payloads.map(\.event) }
    
    init(stub: Stub) {
        
        self.stub = stub
    }
    
    func reduce(
        _ state: State,
        _ event: Event
    ) -> (State, Effect?) {
        
        payloads.append((state, event))
        
        return stub
    }
}
