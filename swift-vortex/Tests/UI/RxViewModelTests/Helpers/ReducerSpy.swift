//
//  ReducerSpy.swift
//
//
//  Created by Igor Malyarov on 20.01.2024.
//

import RxViewModel

final class ReducerSpy<State, Event, Effect>: Reducer
where State: Equatable,
      Event: Equatable,
      Effect: Equatable {
    
    private var stub: [(State, Effect?)]
    private(set) var messages = [Message]()
    
    var callCount: Int { messages.count }
    
    init(stub: [(State, Effect?)]) {
        
        self.stub = stub
    }
    
    func reduce(
        _ state: State,
        _ event: Event
    ) -> (State, Effect?) {
        
        messages.append((state, event))
        let first = stub.removeFirst()
        
        return first
    }
    
    typealias Message = (state: State, event: Event)
}
