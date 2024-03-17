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
    
    private let flowReduce: FlowReduce
    private let flowHandleEffect: FlowHandleEffect
    private let stateSubject = PassthroughSubject<State, Never>()
    
    var rootActions: RootActions?
    
    public init(
        initialState: State,
        flowReduce: @escaping FlowReduce,
        flowHandleEffect: @escaping FlowHandleEffect,
        scheduler: AnySchedulerOf<DispatchQueue> = .main
    ) {
        self.state = initialState
        self.flowReduce = flowReduce
        self.flowHandleEffect = flowHandleEffect
        
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
        
        switch event {
        case let .flow(flowEvent):
            self.event(flowEvent)
            
        case let .tap(tapEvent):
            self.handle(tapEvent)
        }
    }
}

extension PaymentsTransfersViewModel {
    
    typealias FlowReduce = (State, FlowEvent) -> (State, FlowEffect?)
    typealias FlowHandleEffect = (FlowEffect, @escaping FlowDispatch) -> Void
    
    typealias FlowDispatch = (FlowEvent) -> Void
    
    typealias FlowEvent = PaymentsTransfersFlowEvent<LastPayment, Operator, UtilityService, StartPayment>
    typealias FlowEffect = PaymentsTransfersFlowEffect<LastPayment, Operator, UtilityService>
    
    typealias State = PaymentsTransfersState
    typealias Event = PaymentsTransfersEvent
    typealias Effect = PaymentsTransfersEffect
}

private extension PaymentsTransfersViewModel {
    
    func event(_ event: FlowEvent) {
        
        let (state, effect) = reduce(state, event)
        stateSubject.send(state)
        
        if let effect {
            
            flowHandleEffect(effect) { [weak self] in
                
                self?.event(.flow($0))
            }
        }
    }
    
    func reduce(
        _ state: State,
        _ event: FlowEvent
    ) -> (State, Effect?) {
        
        let (state, effect) = flowReduce(state, event)
        
        // decoration
        if effect == nil {
            rootActions?.spinner.hide()
        } else {
            rootActions?.spinner.show()
        }
        
        return (state, effect)
    }
    
    func handle(_ tapEvent: Event.TapEvent) {
        
        switch tapEvent {
        case .addCompany:
            addCompany()

        case .goToMain:
            goToMain()
        }
    }
    
    func addCompany() {
        
        fatalError()
    }
    
    func goToMain() {
        
        fatalError()
    }
}
