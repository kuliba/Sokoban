//
//  PayHubEffectHandler.swift
//
//
//  Created by Igor Malyarov on 15.08.2024.
//

final class PayHubEffectHandler<Exchange, Latest, Templates>
where Exchange: FlowEventEmitter,
      Templates: FlowEventEmitter,
      Exchange.Status == Templates.Status {
    
    let microServices: MicroServices
    
    init(microServices: MicroServices) {
        
        self.microServices = microServices
    }
    
    typealias MicroServices = PayHubEffectHandlerMicroServices<Exchange, Latest, Templates>
}

extension PayHubEffectHandler {
    
    func handleEffect(
        _ effect: Effect,
        _ dispatch: @escaping Dispatch
    ) {
        switch effect {
        case .load:
            let templatesNode = makeTemplatesNode(dispatch)
            let exchangeNode = makeExchangeNode(dispatch)
            
            microServices.load {
                
                let latests = (try? $0.get()) ?? []
                let loaded = [.templates(templatesNode), .exchange(exchangeNode)
                ] + latests.map(Item.latest)
                dispatch(.loaded(loaded))
            }
        }
    }
    
    typealias Item = PayHubItem<Exchange, Latest, Templates>
}

extension PayHubEffectHandler {
    
    typealias Dispatch = (Event) -> Void
    
    typealias Event = PayHubEvent<Exchange, Latest, Exchange.Status, Templates>
    typealias Effect = PayHubEffect
}

private extension PayHubEffectHandler {
    
    func makeTemplatesNode(
        _ dispatch: @escaping Dispatch
    ) -> Node<Templates> {
        
        let templates = microServices.makeTemplates()
        let cancellable = templates.eventPublisher
            .sink { dispatch(.flowEvent($0)) }
        
        return .init(model: templates, cancellable: cancellable)
    }
    
    func makeExchangeNode(
        _ dispatch: @escaping Dispatch
    ) -> Node<Exchange> {
        
        let exchange = microServices.makeExchange()
        let cancellable = exchange.eventPublisher
            .sink { dispatch(.flowEvent($0)) }
        
        return .init(model: exchange, cancellable: cancellable)
    }
}
