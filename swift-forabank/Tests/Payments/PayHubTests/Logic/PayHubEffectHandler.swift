//
//  PayHubEffectHandler.swift
//
//
//  Created by Igor Malyarov on 15.08.2024.
//

final class PayHubEffectHandler<Exchange, Latest, LatestFlow, Templates>
where Exchange: FlowEventEmitter,
      LatestFlow: FlowEventEmitter,
      Templates: FlowEventEmitter,
      Exchange.Status == LatestFlow.Status ,
      Exchange.Status == Templates.Status {
    
    let microServices: MicroServices
    
    init(microServices: MicroServices) {
        
        self.microServices = microServices
    }
    
    typealias MicroServices = PayHubEffectHandlerMicroServices<Exchange, Latest, LatestFlow, Templates>
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
            
            microServices.load { [weak self] in
                
                guard let self else { return }
                
                let latests = ((try? $0.get()) ?? [])
                let latestFlows = latests.map { self.makeLatestNode($0, dispatch) }
                
                let loaded = [Item.templates(templatesNode), .exchange(exchangeNode)
                ] + latestFlows.map(Item.latest)
                dispatch(.loaded(loaded))
            }
        }
    }
    
    typealias Item = PayHubItem<Exchange, LatestFlow, Templates>
}

extension PayHubEffectHandler {
    
    typealias Dispatch = (Event) -> Void
    
    typealias Event = PayHubEvent<Exchange, LatestFlow, Exchange.Status, Templates>
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
    
    func makeLatestNode(
        _ latest: Latest,
        _ dispatch: @escaping Dispatch
    ) -> Node<LatestFlow> {
        
        let latestFlow = microServices.makeLatestFlow(latest)
        let cancellable = latestFlow.eventPublisher
            .sink { dispatch(.flowEvent($0)) }
        
        return .init(model: latestFlow, cancellable: cancellable)
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
