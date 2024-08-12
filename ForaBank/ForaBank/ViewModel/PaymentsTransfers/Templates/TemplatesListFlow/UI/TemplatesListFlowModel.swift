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
    
    private let reduce: Reduce
    private let handleEffect: HandleEffect
    
    private let stateSubject = PassthroughSubject<State, Never>()
    private var cancellables = Set<AnyCancellable>()
    
    init(
        initialState: State,
        reduce: @escaping Reduce,
        handleEffect: @escaping HandleEffect,
        scheduler: AnySchedulerOf<DispatchQueue>
    ) {
        self.state = initialState
        self.reduce = reduce
        self.handleEffect = handleEffect
        
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
    
    typealias Reduce = (State, Event) -> (State, Effect?)
    typealias Dispatch = (Event) -> Void
    typealias HandleEffect = (Effect, @escaping Dispatch) -> Void
}

extension TemplatesListFlowModel {
    
    func event(_ event: Event) {
        
        let (state, effect) = reduce(state, event)
        stateSubject.send(state)
        
        if let effect {
            
            handleEffect(effect) { [weak self] in self?.event($0) }
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
