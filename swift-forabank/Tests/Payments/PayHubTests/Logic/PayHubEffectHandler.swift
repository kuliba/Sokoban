//
//  PayHubEffectHandler.swift
//
//
//  Created by Igor Malyarov on 15.08.2024.
//

final class PayHubEffectHandler<Latest, Status, TemplatesFlow>
where TemplatesFlow: FlowEventEmitter,
      TemplatesFlow.Status == Status {
    
    let microServices: MicroServices
    
    init(microServices: MicroServices) {
        
        self.microServices = microServices
    }
    
    typealias MicroServices = PayHubEffectHandlerMicroServices<Latest, TemplatesFlow>
}

extension PayHubEffectHandler {
    
    func handleEffect(
        _ effect: Effect,
        _ dispatch: @escaping Dispatch
    ) {
        switch effect {
        case .load:
            let templatesNode = makeTemplatesNode(dispatch)
            
            microServices.load {
                
                let latests = (try? $0.get()) ?? []
                let loaded = [.templates(templatesNode), .exchange] + latests.map(Item.latest)
                dispatch(.loaded(loaded))
            }
        }
    }
    
    typealias Item = PayHubItem<Latest, TemplatesFlow>
}

extension PayHubEffectHandler {
    
    typealias Dispatch = (Event) -> Void
    
    typealias Event = PayHubEvent<Latest, Status, TemplatesFlow>
    typealias Effect = PayHubEffect
}

private extension PayHubEffectHandler {
    
    func makeTemplatesNode(
        _ dispatch: @escaping Dispatch
    ) -> Node<TemplatesFlow> {
        
        let templates = microServices.makeTemplates()
        let cancellable = templates.eventPublisher
            .sink { dispatch(.flowEvent($0)) }
        
        return .init(model: templates, cancellable: cancellable)
    }
}
