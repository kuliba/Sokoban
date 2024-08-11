//
//  TemplatesListFlowModel.swift
//  ForaBank
//
//  Created by Igor Malyarov on 09.08.2024.
//

import Combine
import CombineSchedulers
import Foundation

final class TemplatesListFlowModel<Content>: ObservableObject
where Content: ProductIDEmitter {
    
    @Published private(set) var state: State
    
    private let stateSubject = PassthroughSubject<State, Never>()
    private var cancellables = Set<AnyCancellable>()
    
    init(
        initialState: State,
        scheduler: AnySchedulerOf<DispatchQueue>
    ) {
        self.state = initialState
        
        stateSubject
            .receive(on: scheduler)
            .assign(to: &$state)
        
        bind(state.content, on: scheduler)
    }
}

extension TemplatesListFlowModel {
    
    typealias State = TemplatesListFlowState<Content>
    typealias Event = TemplatesListFlowEvent
}

extension TemplatesListFlowModel {
    
    func event(_ event: Event) {
        
        var state = state
        
        switch event {
        case let .select(productID):
            state.status = .outside(.productID(productID))
        }
        
        stateSubject.send(state)
    }
}

private extension TemplatesListFlowModel {
    
    func bind(
        _ content: Content,
        on scheduler: AnySchedulerOf<DispatchQueue>
    ) {
        content.productIDPublisher
            .receive(on: scheduler)
            .sink { [weak self] in self?.event(.select($0)) }
            .store(in: &cancellables)
    }
}
