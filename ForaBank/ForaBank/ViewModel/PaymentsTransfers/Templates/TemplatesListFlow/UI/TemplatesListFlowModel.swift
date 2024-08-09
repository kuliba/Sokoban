//
//  TemplatesListFlowModel.swift
//  ForaBank
//
//  Created by Igor Malyarov on 09.08.2024.
//

import Combine
import CombineSchedulers
import Foundation

protocol ProductIDEmitter {
    
    typealias ProductID = ProductData.ID
    
    var productIDPublisher: AnyPublisher<ProductID, Never> { get }
}

protocol TemplateEmitter {
    
    var templatePublisher: AnyPublisher<PaymentTemplateData, Never> { get }
}

final class TemplatesListFlowModel<Content>: ObservableObject
where Content: ProductIDEmitter & TemplateEmitter {
    
    @Published private(set) var state: State
    
    private let factory: Factory
    
    private let stateSubject = PassthroughSubject<State, Never>()
    private var cancellables = Set<AnyCancellable>()
    
    init(
        initialState: State,
        factory: Factory,
        scheduler: AnySchedulerOf<DispatchQueue>
    ) {
        self.state = initialState
        self.factory = factory
        
        stateSubject
            .receive(on: scheduler)
            .assign(to: &$state)
        
        bind(state.content, on: scheduler)
    }
}

extension TemplatesListFlowModel {
    
    typealias State = TemplatesListFlowState<Content>
    typealias Event = TemplatesListFlowEvent
    typealias Effect = TemplatesListFlowEffect
    typealias Factory = TemplatesListFlowModelFactory
}

extension TemplatesListFlowModel {
    
    func event(_ event: Event) {
        
        var state = state
        let effect = reduce(&state, event)
        stateSubject.send(state)
        
        if let effect {
            
            handleEffect(effect) { [weak self] in self?.event($0) }
        }
    }
    
    func handleEffect(
        _ effect: Effect,
        _ dispatch: @escaping (Event) -> Void
    ) {
        switch effect {
        case let .template(template):
            let model = factory.makePaymentModel(template) { [weak self] in
                
                self?.event(.dismiss(.destination))
            }
            self.event(.payment(model))
        }
    }
}

private extension TemplatesListFlowModel {
    
    func bind(
        _ content: Content,
        on scheduler: AnySchedulerOf<DispatchQueue>
    ) {
        content.productIDPublisher
            .receive(on: scheduler)
            .sink { [weak self] in self?.event(.select(.productID($0))) }
            .store(in: &cancellables)
        
        content.templatePublisher
            .receive(on: scheduler)
            .sink { [weak self] in self?.event(.select(.template($0))) }
            .store(in: &cancellables)
    }
}

private extension TemplatesListFlowModel {
    
    func reduce(
        _ state: inout State,
        _ event: Event
    ) -> Effect? {
        
        var effect: Effect?
        
        switch event {
        case .dismiss(.destination):
            state.status = nil
            
        case let .payment(payment):
            state.status = .destination(.payment(payment))
            
        case let .select(select):
            switch select {
            case let .productID(productID):
                state.status = .outside(.productID(productID))
                
            case let .template(template):
                state.status = .outside(.inflight)
                effect = .template(template)
            }
        }
        
        return effect
    }
}
