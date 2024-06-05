//
//  RxCachedModelsViewModel.swift
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

final class CachedPaymentViewModel: ObservableObject {
    
    @Published private(set) var state: State
    
    private var cancellables = Set<AnyCancellable>()
    
    init(
        source: Source,
        map: @escaping Map,
        scheduler: AnySchedulerOfDispatchQueue = .makeMain()
    ) {
        let pairs = source.state.fields.map { ($0.id, map($0)) }
        let initialState = State(pairs: pairs)
        self.state = initialState
        
        source.$state
            .receive(on: scheduler)
            .sink { [weak self] payment in
                
                guard let self else { return }
                
                self.state = self.state.updating(with: payment.fields, using: map)
            }
            .store(in: &cancellables)
    }
    
    typealias State = CachedPayment
    typealias Source = RxViewModel<Payment, PaymentEvent, PaymentEffect>
    typealias Map = (CachedPayment.Field) -> CachedPayment.FieldModel
}
