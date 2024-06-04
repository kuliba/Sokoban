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
        map: @escaping (Input) -> Output
    ) {
        self.state = map(source.state)
        self.source = source
        
        source.$state
            .dropFirst()
            .map(map)
            .assign(to: &$state)
    }
    
    typealias State = Output
    typealias Source = RxViewModel<Input, Event, Effect>
}

extension RxMappingViewModel {
    
    func event(_ event: Event) {
        
        source.event(event)
    }
}
