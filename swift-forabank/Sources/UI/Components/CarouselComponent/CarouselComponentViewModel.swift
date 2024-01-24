//
//  CarouselComponentViewModel.swift
//
//
//  Created by Disman Dmitry on 22.01.2024.
//

import SwiftUI

final public class CarouselComponentViewModel: ObservableObject {
    
    typealias Reduce = (State, Event) -> State
    
    @Published var state: State
    
    let reduce: Reduce

    init(
        initialState: State,
        reduce: @escaping Reduce
    ) {
        self.state = initialState
        self.reduce = reduce
    }
    
    func event(_ event: Event) {
        
        state = reduce(state, event)
    }
}
