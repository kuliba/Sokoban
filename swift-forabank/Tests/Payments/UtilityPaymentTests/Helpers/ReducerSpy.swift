//
//  ReducerSpy.swift
//
//
//  Created by Igor Malyarov on 20.01.2024.
//

final class ReducerSpy<State, Event, Effect> {
    
    private var stub: [(State, Effect?)]
    private(set) var messages = [Message]()
    
    init(stub: [(State, Effect?)]) {
        
        self.stub = stub
    }
}

extension ReducerSpy {
    
    var callCount: Int { messages.count }
    
    func reduce(
        _ state: State,
        _ event: Event
    ) -> (State, Effect?) {
        
        messages.append((state, event))
        let first = stub.removeFirst()
        
        return first
    }
}

extension ReducerSpy {
    
    typealias Message = (state: State, event: Event)
}
