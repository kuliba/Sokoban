//
//  PayHubFlowTests.swift
//
//
//  Created by Igor Malyarov on 15.08.2024.
//

import Combine
import PayHub
import XCTest

class PayHubFlowTests: XCTestCase {
    
    typealias Exchange = Flow
    typealias LatestFlow = Flow
    typealias Templates = Flow
    
    struct Latest: Hashable {
        
        let value: String
    }
    
    func makeLatest(
        _ value: String = anyMessage()
    ) -> Latest {
        
        return .init(value: value)
    }
    
    struct Status: Equatable {
        
        let value: String
    }
    
    func makeStatus(
        _ value: String = anyMessage()
    ) -> Status {
        
        return .init(value: value)
    }
    
    func makeExchangeFlow() -> Flow {
        
        return .init()
    }
    
    func makeExchangeFlowNode() -> Node<Flow> {
        
        let flow = makeExchangeFlow()
        let cancellable = flow.eventPublisher.sink { _ in }
        
        return .init(model: flow, cancellable: cancellable)
    }
    
    func makeLatestFlow() -> Flow {
        
        return .init()
    }
    
    func makeLatestFlowNode() -> Node<Flow> {
        
        let flow = makeLatestFlow()
        let cancellable = flow.eventPublisher.sink { _ in }
        
        return .init(model: flow, cancellable: cancellable)
    }
    
    func makeTemplatesFlow() -> Flow {
        
        return .init()
    }
    
    func makeTemplatesFlowNode() -> Node<Flow> {
        
        let flow = makeTemplatesFlow()
        let cancellable = flow.eventPublisher.sink { _ in }
        
        return .init(model: flow, cancellable: cancellable)
    }
    
    final class Flow: FlowEventEmitter {
        
        typealias Event = FlowEvent<Status>
        
        private let subject = PassthroughSubject<Event, Never>()
        
        var eventPublisher: AnyPublisher<Event, Never> {
            
            subject.eraseToAnyPublisher()
        }
        
        func emit(_ event: Event) {
            
            subject.send(event)
        }
    }
}

extension PayHubFlowItem where Exchange: AnyObject, Latest: AnyObject, Templates: AnyObject {
    
    var equatableProjection: EquatableProjection {
        
        switch self {
        case let .exchange(node):
            return .exchange(ObjectIdentifier(node.model))
            
        case let .latest(node):
            return .latest(ObjectIdentifier(node.model))
            
        case let .templates(node):
            return .templates(ObjectIdentifier(node.model))
        }
    }
    
    enum EquatableProjection: Equatable {
        
        case exchange(ObjectIdentifier)
        case latest(ObjectIdentifier)
        case templates(ObjectIdentifier)
    }
}

extension PayHubFlowEvent
where Exchange: AnyObject,
      Latest: Equatable,
      LatestFlow: AnyObject,
      Status: Equatable,
      Templates: AnyObject {
    
    var equatableProjection: EquatableProjection {
        
        switch self {
        case let .flowEvent(flowEvent):
            return .flowEvent(flowEvent)
            
        case let .select(select):
            return .select(select)
            
        case let .selected(selected):
            return .selected(selected?.equatableProjection)
        }
    }
    
    enum EquatableProjection: Equatable {
        
        case flowEvent(FlowEvent<Status>)
        case select(PayHubItem<Latest>?)
        case selected(PayHubFlowItem<Exchange, LatestFlow, Templates>.EquatableProjection?)
    }
}
