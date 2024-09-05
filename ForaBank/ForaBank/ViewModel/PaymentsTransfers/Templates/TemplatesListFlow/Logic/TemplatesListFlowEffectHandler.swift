//
//  TemplatesListFlowEffectHandler.swift
//  ForaBank
//
//  Created by Igor Malyarov on 09.08.2024.
//

final class TemplatesListFlowEffectHandler<PaymentFlow>
where PaymentFlow: FlowEventPublishing {
    
    private let microServices: MicroServices
    
    init(
        microServices: MicroServices
    ) {
        self.microServices = microServices
    }
    
    typealias MicroServices = TemplatesListFlowEffectHandlerMicroServices<PaymentsViewModel, PaymentFlow>
}

extension TemplatesListFlowEffectHandler {
    
    func handleEffect(
        _ effect: Effect,
        _ dispatch: @escaping Dispatch
    ) {
        switch effect {
        case let .template(template):
            let payload = (template, { dispatch(.dismiss(.destination)) })
            microServices.makePayment(payload) { [weak self] in
                
                self?.handle($0, dispatch)
            }
        }
    }
}

extension TemplatesListFlowEffectHandler {
    
    typealias Dispatch = (Event) -> Void
    
    typealias Event = TemplatesListFlowEvent<PaymentFlow>
    typealias Effect = TemplatesListFlowEffect
}

private extension TemplatesListFlowEffectHandler {
    
    func handle(
        _ result: MicroServices.MakePaymentResult,
        _ dispatch: @escaping Dispatch
    ) {
        switch result {
        case let .failure(serviceFailure):
            dispatch(.payment(.failure(serviceFailure)))
            
        case let .success(success):
            switch success {
            case let .legacy(legacy):
                dispatch(.payment(.success(.legacy(legacy))))
                
            case let .v1(paymentFlow):
                let cancellable = paymentFlow.flowEventPublisher
                    .sink { dispatch(.flow($0)) }
                
                dispatch(.payment(.success(.v1(.init(
                    model: paymentFlow,
                    cancellable: cancellable
                )))))
            }
        }
    }
}
