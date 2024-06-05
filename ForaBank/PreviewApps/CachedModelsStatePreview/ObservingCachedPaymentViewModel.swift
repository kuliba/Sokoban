//
//  ObservingCachedPaymentViewModel.swift
//  CachedModelsStatePreview
//
//  Created by Igor Malyarov on 05.06.2024.
//

import Combine
import CombineSchedulers
import ForaTools
import Foundation
import RxViewModel

typealias AnySchedulerOfDispatchQueue = AnySchedulerOf<DispatchQueue>

extension AnySchedulerOfDispatchQueue {
    
    static func makeMain() -> AnySchedulerOfDispatchQueue { .main }
}

final class ObservingCachedPaymentViewModel: ObservableObject {
    
    @Published private(set) var state: State
    
    private let source: Source
    private var cancellables = Set<AnyCancellable>()
    
    init(
        source: Source,
        map: @escaping Map,
        observe: @escaping Observe,
        scheduler: AnySchedulerOfDispatchQueue = .makeMain()
    ) {
        let pairs = source.state.fields.map { ($0.id, map($0)) }
        let initialState = State(pairs: pairs)
        self.state = initialState
        self.source = source
        
        source.$state
            .compactMap { [weak self] payment in
                
                guard let self else { return nil }
                
                return self.state.updating(with: payment.fields, using: map)
            }
            .scan((initialState, initialState)) { ($0.1, $1) }
            .handleEvents(receiveOutput: observe)
            .map(\.1)
            .receive(on: scheduler)
            .assign(to: &$state)
    }
    
    typealias State = CachedPayment
    typealias Event = PaymentEvent
    typealias Source = RxViewModel<Payment, PaymentEvent, PaymentEffect>
    typealias Map = (CachedPayment.Field) -> CachedPayment.FieldModel
    typealias Observe = (State, State) -> Void
}

extension ObservingCachedPaymentViewModel {
    
    func event(_ event: Event) {
        
        source.event(event)
    }
}
