//
//  MarketShowcaseComposer.swift
//  ForaBank
//
//  Created by Andryusina Nataly on 25.09.2024.
//

import CombineSchedulers
import Foundation

final class MarketShowcaseComposer {
    
    private let nanoServices: NanoServices
    private let scheduler: AnySchedulerOf<DispatchQueue>
    
    init(
        nanoServices: NanoServices,
        scheduler: AnySchedulerOf<DispatchQueue>
    ) {
        self.nanoServices = nanoServices
        self.scheduler = scheduler
    }
    
    typealias NanoServices = MarketShowcaseComposerNanoServices
}

extension MarketShowcaseComposer {
    
    func compose() -> MarketShowcaseDomain.Binder {
        
        let content = makeContent(status: .initiate)
        let flow = makeFlow()
        
        return .init(
            content: content,
            flow: flow,
            bind: { content, flow in
                
                let select = content.$state
                    .compactMap(\.selection)
                    .sink { [weak flow] in
                        
                        switch $0 {
                            
                        case .landingType("orderCard"):
                            flow?.event(.select(.orderCard))
                            
                        case .landingType("orderSticker"):
                            flow?.event(.select(.orderSticker))
                            
                        case let .landingType(type):
                            flow?.event(.select(.landing(type)))
                        }
                    }
                
                let failureInfo = content.$state
                    .compactMap { $0.status }
                    .sink { [weak flow] in
                        
                        switch $0 {
                            
                        case .initiate, .inflight, .loaded:
                            break
                        case let .failure(kind):
                            switch kind {
                                
                            case let .alert(message):
                                flow?.event(.failure(.error(message)))
                            case let .informer(informerPayload):
                                flow?.event(.failure(.timeout(informerPayload)))
                            }
                        }
                    }

                let status = flow.$state.map(\.status)
                let reset = status
                    .combineLatest(status.dropFirst())
                    .filter { $0.0 != nil && $0.1 == nil }
                    .sink { [weak content] _ in content?.event(.resetSelection)}
                
                return [select, failureInfo, reset]
            })
    }
}

private extension MarketShowcaseComposer {
    
    func makeContent(
        status: MarketShowcaseDomain.ContentStatus
    ) -> MarketShowcaseDomain.Content {
        
        let reducer = MarketShowcaseDomain.ContentReducer()
        let effectHandler = MarketShowcaseDomain.ContentEffectHandler(
            microServices: .init(
                loadLanding: nanoServices.loadLanding
            ), 
            landingType: AbroadType.marketShowcase.rawValue
        )
        return .init(
            initialState: .init(status: status),
            reduce: reducer.reduce(_:_:),
            handleEffect: effectHandler.handleEffect,
            scheduler: scheduler
        )
    }
    
    func makeFlow() -> MarketShowcaseDomain.Flow {
        
        let reducer = MarketShowcaseDomain.FlowReducer()
        let effectHandler = MarketShowcaseDomain.FlowEffectHandler(
            microServices: .init(
                orderCard: nanoServices.orderCard,
                orderSticker: nanoServices.orderSticker,
                showLanding: { type,_ in self.nanoServices.loadLanding(type) {_ in
                    
                    let _ = print("load landing \(type)")
                }}
            ))
        return .init(
            initialState: .init(),
            reduce: reducer.reduce(_:_:),
            handleEffect: effectHandler.handleEffect,
            scheduler: scheduler
        )
    }
}
