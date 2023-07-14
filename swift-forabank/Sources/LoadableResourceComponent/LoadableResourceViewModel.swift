//
//  LoadableResourceViewModel.swift
//  
//
//  Created by Igor Malyarov on 23.06.2023.
//

import Combine

public final class LoadableResourceViewModel<Resource>: ObservableObject {
    
    @Published public private(set) var state: State = .loading
    
    public init(
        publisher: AnyPublisher<Resource, Error>,
        scheduler: AnySchedulerOfDispatchQueue = .makeMain()
    ) {
        publisher
            .map(State.loaded)
            .catch { Just(State.error($0)) }
            .receive(on: scheduler)
            .assign(to: &$state)
    }
    
    public enum State {
        
        case error(Error)
        case loaded(Resource)
        case loading
    }
}
