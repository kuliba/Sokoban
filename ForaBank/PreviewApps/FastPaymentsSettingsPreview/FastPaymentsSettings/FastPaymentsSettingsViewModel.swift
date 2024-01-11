//
//  FastPaymentsSettingsViewModel.swift
//  FastPaymentsSettingsPreview
//
//  Created by Igor Malyarov on 11.01.2024.
//

import Foundation

final class FastPaymentsSettingsViewModel: ObservableObject {
    
    @Published private(set) var state: State?
    
    private let reduce: Reduce
    
    init(
        state: State? = nil,
        reduce: @escaping Reduce
    ) {
        self.state = state
        self.reduce = reduce
    }
}

extension FastPaymentsSettingsViewModel {
    
    func event(_ event: Event) {
        
        reduce(state, event) { [weak self] in self?.state = $0 }
    }
}

extension FastPaymentsSettingsViewModel {
    
    struct State {}
    enum Event {
        
        case appear
    }
}

extension FastPaymentsSettingsViewModel {

    typealias Reduce = (State?, Event, @escaping (State?) -> Void) -> Void
}
