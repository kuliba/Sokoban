//
//  ViewModel.swift
//  FastPaymentsSettingsPreview
//
//  Created by Igor Malyarov on 13.01.2024.
//

import Foundation

final class ViewModel<State, Event>: ObservableObject {
    
    @Published private(set) var state: State
    
    private let reduce: Reduce
    
    init(
        initialState: State,
        reduce: @escaping Reduce
    ) {
        self.state = initialState
        self.reduce = reduce
    }
}

extension ViewModel {
    
    func event(_ event: Event) {
        
        reduce(state, event) { self.state = $0 }
    }
}

extension ViewModel {
    
    typealias Reduce = (State, Event, @escaping (State) -> Void) -> Void
}
