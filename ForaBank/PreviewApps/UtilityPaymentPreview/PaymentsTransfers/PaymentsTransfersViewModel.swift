//
//  PaymentsTransfersViewModel.swift
//  ForaBank
//
//  Created by Igor Malyarov on 03.03.2024.
//

import Combine
import CombineSchedulers
import Foundation
import UtilityPayment

final class PaymentsTransfersViewModel: ObservableObject {
    
    @Published public private(set) var state: State
    
    private let paymentsTransfersReduce: PaymentsTransfersReduce
    private let paymentsTransfersHandleEffect: PaymentsTransfersHandleEffect
    private let stateSubject = PassthroughSubject<State, Never>()
    
    var rootActions: RootActions?
    
    public init(
        initialState: State,
        paymentsTransfersReduce: @escaping PaymentsTransfersReduce,
        paymentsTransfersHandleEffect: @escaping PaymentsTransfersHandleEffect,
        scheduler: AnySchedulerOf<DispatchQueue> = .main
    ) {
        self.state = initialState
        self.paymentsTransfersReduce = paymentsTransfersReduce
        self.paymentsTransfersHandleEffect = paymentsTransfersHandleEffect
        
        stateSubject
            .removeDuplicates()
            .receive(on: scheduler)
            .assign(to: &$state)
    }
    
    deinit {
        
        print("deinit: \(type(of: Self.self))")
    }
}

extension PaymentsTransfersViewModel {
    
    func event(_ event: Event) {
        
        let (state, effect) = reduce(state, event)
        stateSubject.send(state)
        
        if let effect {
            
            paymentsTransfersHandleEffect(effect) { [weak self] event in
                
                self?.event(event)
            }
        }
    }
}

private extension PaymentsTransfersViewModel {
    
    func reduce(
        _ state: State,
        _ event: Event
    ) -> (State, Effect?) {
        
        let (state, effect) = paymentsTransfersReduce(state, event)
        
        // decoration
        if effect == nil {
            rootActions?.spinner.hide()
        } else {
            rootActions?.spinner.show()
        }
        
        return (state, effect)
    }
}

extension PaymentsTransfersViewModel {
    
    typealias PaymentsTransfersReduce = (State, Event) -> (State, Effect?)
    typealias PaymentsTransfersHandleEffect = (Effect, @escaping Dispatch) -> Void
    
    typealias Dispatch = (Event) -> Void
    
    typealias State = PaymentsTransfersState
    typealias Event = PaymentsTransfersEvent<LastPayment, Operator, UtilityService, StartPayment>
    typealias Effect = PaymentsTransfersEffect<LastPayment, Operator, UtilityService>
}
