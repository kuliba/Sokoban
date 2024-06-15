//
//  SwiftUIView.swift
//  
//
//  Created by Igor Malyarov on 15.06.2024.
//

public extension SelectorView where T: Hashable, T == ID {
    
    init(
        state: State,
        event: @escaping (Event) -> Void,
        factory: Factory
    ) {
        self.init(
            state: state,
            event: event,
            factory: factory,
            idKeyPath: \.self
        )
    }
}

public extension SelectorView where T: Identifiable, T.ID == ID {
    
    init(
        state: State,
        event: @escaping (Event) -> Void,
        factory: Factory
    ) {
        self.init(
            state: state,
            event: event,
            factory: factory,
            idKeyPath: \.id
        )
    }
}
