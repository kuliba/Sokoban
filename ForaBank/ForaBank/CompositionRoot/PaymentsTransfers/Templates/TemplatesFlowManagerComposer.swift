//
//  TemplatesFlowManagerComposer.swift
//  ForaBank
//
//  Created by Igor Malyarov on 04.07.2024.
//

import Foundation

final class TemplatesFlowManagerComposer {
    
    private let flag: UtilitiesPaymentsFlag
    
    init(
        flag: UtilitiesPaymentsFlag
    ) {
        self.flag = flag
    }
}

extension TemplatesFlowManagerComposer {
    
    func compose() -> TemplatesFlowManager {
        
        return .init(reduce: reduce, handleEffect: handleEffect)
    }
}

private extension TemplatesFlowManagerComposer {
    
    func reduce(
        state: State,
        event: Event
    ) -> (State, Effect?) {
        
        switch event {
        case .paymentInitiationResult:
            fatalError("Should not be processed in the `reduce` yet")
            
        case let .paymentTemplateSelected(template):
            switch flag.rawValue {
            case .active:
                return (.v1, .initiatingPayment(template))
                
            case .inactive:
                return (.legacy(template), nil)
            }
        }
    }
    
    func handleEffect(
        effect: Effect,
        dispatch: @escaping Dispatch
    ) {
        DispatchQueue.main.delay(
            for: .seconds(2)
        ) {
            dispatch(.paymentInitiationResult(.failure(.init(message: "Payment Initiation Failure"))))
        }
    }
    
    typealias State = TemplatesFlowManager.State
    typealias Event = TemplatesFlowManager.Event
    typealias Effect = TemplatesFlowManager.Effect
    typealias Dispatch = TemplatesFlowManager.Dispatch
}
