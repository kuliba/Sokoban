//
//  PayHubFlowEffectHandler.swift
//
//
//  Created by Igor Malyarov on 15.08.2024.
//

public final class PayHubFlowEffectHandler<Exchange, Latest, LatestFlow, Templates>
where Exchange: FlowEventEmitter,
      LatestFlow: FlowEventEmitter,
      Templates: FlowEventEmitter,
      Exchange.Status == LatestFlow.Status ,
      Exchange.Status == Templates.Status {
    
    let microServices: MicroServices
    
    public init(microServices: MicroServices) {
        
        self.microServices = microServices
    }
    
    public typealias MicroServices = PayHubFlowEffectHandlerMicroServices<Exchange, Latest, LatestFlow, Templates>
}

public extension PayHubFlowEffectHandler {
    
    func handleEffect(
        _ effect: Effect,
        _ dispatch: @escaping Dispatch
    ) {
        switch effect {
        case let .select(item):
            select(item, dispatch)
        }
    }
    
    typealias Item = PayHubFlowItem<Exchange, LatestFlow, Templates>
}

public extension PayHubFlowEffectHandler {
    
    typealias Dispatch = (Event) -> Void
    
    typealias Event = PayHubFlowEvent<Exchange, Latest, LatestFlow, Exchange.Status, Templates>
    typealias Effect = PayHubFlowEffect<Latest>
}

private extension PayHubFlowEffectHandler {
    
    func select(
        _ item: PayHubItem<Latest>?,
        _ dispatch: @escaping Dispatch
    ) {
        var selected: Item?
        
        switch item {
        case .none:
            break

        case .exchange:
            let exchangeNode = makeExchangeNode(dispatch)
            selected = .exchange(exchangeNode)
            
        case let .latest(latest):
            let latestNode = makeLatestNode(latest, dispatch)
            selected = .latest(latestNode)
            
        case .templates:
            let templatesNode = makeTemplatesNode(dispatch)
            selected = .templates(templatesNode)
        }

        dispatch(.selected(selected))
    }
    
    private func makeTemplatesNode(
        _ dispatch: @escaping Dispatch
    ) -> Node<Templates> {
        
        let templates = microServices.makeTemplates()
        let cancellable = templates.eventPublisher
            .sink { dispatch(.flowEvent($0)) }
        
        return .init(model: templates, cancellable: cancellable)
    }
    
    private func makeLatestNode(
        _ latest: Latest,
        _ dispatch: @escaping Dispatch
    ) -> Node<LatestFlow> {
        
        let latestFlow = microServices.makeLatestFlow(latest)
        let cancellable = latestFlow.eventPublisher
            .sink { dispatch(.flowEvent($0)) }
        
        return .init(model: latestFlow, cancellable: cancellable)
    }
    
    private func makeExchangeNode(
        _ dispatch: @escaping Dispatch
    ) -> Node<Exchange> {
        
        let exchange = microServices.makeExchange()
        let cancellable = exchange.eventPublisher
            .sink { dispatch(.flowEvent($0)) }
        
        return .init(model: exchange, cancellable: cancellable)
    }
}
