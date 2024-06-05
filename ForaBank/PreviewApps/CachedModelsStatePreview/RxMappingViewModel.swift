//
//  RxMappingViewModel.swift
//
//
//  Created by Igor Malyarov on 04.06.2024.
//

import Foundation
import RxViewModel

final class RxMappingViewModel<Input, Output, Event, Effect>: ObservableObject {
    
    @Published private(set) var state: State
    
    private let source: Source
    
    init(
        source: Source,
        map: @escaping Map,
        observe: @escaping Observe
    ) {
        let initialState = map(source.state)
        self.state = initialState
        self.source = source
        
        source.$state
            .dropFirst()
            .map(map)
            .scan((initialState, initialState)) { ($0.1, $1) }
            .handleEvents(receiveOutput: observe)
            .map(\.1)
            .assign(to: &$state)
    }
    
    typealias State = Output
    typealias Source = RxViewModel<Input, Event, Effect>
    typealias Map = (Input) -> Output
    typealias Observe = (State, State) -> Void
}

extension RxMappingViewModel {
    
    func event(_ event: Event) {
        
        source.event(event)
    }
}
