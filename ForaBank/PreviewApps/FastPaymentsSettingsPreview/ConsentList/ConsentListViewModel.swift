//
//  ConsentListViewModel.swift
//  FastPaymentsSettingsPreview
//
//  Created by Igor Malyarov on 13.01.2024.
//

import Foundation

final class ConsentListViewModel<State, Event>: ObservableObject {
    
    @Published private(set) var state: State
    
    private let reduce: Reduce
    
    init(
        state: State,
        reduce: @escaping Reduce
    ) {
        self.state = state
        self.reduce = reduce
    }
}

extension ConsentListViewModel {

    func event(_ event: Event) {
        
        reduce(state, event) { self.state = $0 }
    }
}

extension ConsentListViewModel {
    
    typealias Reduce = (State, Event, @escaping (State) -> Void) -> Void
}
