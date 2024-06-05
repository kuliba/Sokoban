//
//  RxObservingViewModel.swift
//
//
//  Created by Igor Malyarov on 20.04.2024.
//

import Combine
import Foundation

public final class RxObservingViewModel<State, Event, Effect>: ObservableObject {
    
    @Published public private(set) var state: State
    
    private let observable: ObservableViewModel
    
    public init(
        observable: ObservableViewModel,
        observe: @escaping Observe,
        scheduler: AnySchedulerOfDispatchQueue = .makeMain()
    ) {
        self.state = observable.state
        self.observable = observable
        
        observable.$state
            .dropFirst()
            .scan((observable.state, observable.state)) { ($0.1, $1) }
            .handleEvents(receiveOutput: observe)
            .map(\.1)
            .receive(on: scheduler)
            .assign(to: &$state)
        
        print(">>>>>> \(self) init")
    }
    
    deinit {
        
        print(">>>>>> \(self) deinit")
    }
}

public extension RxObservingViewModel {
    
    func event(_ event: Event) {
        
        observable.event(event)
    }
}

public extension RxObservingViewModel {
    
    typealias ObservableViewModel = RxViewModel<State, Event, Effect>
    typealias Observe = (State, State) -> Void
}
