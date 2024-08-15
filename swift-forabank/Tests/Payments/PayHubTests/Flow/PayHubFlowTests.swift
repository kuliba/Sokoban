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
    
    func makeTemplatesFlow() -> Flow {
        
        return .init()
    }
    
    func makeExchangeFlow() -> Flow {
        
        return .init()
    }
    
    func makeLatestFlow() -> Flow {
        
        return .init()
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

extension PayHubFlowEvent where Exchange: AnyObject, Latest: AnyObject, Status: Equatable, Templates: AnyObject {
    
    var equatableProjection: EquatableProjection {
        
        switch self {
        case let .flowEvent(flowEvent):
            return .flowEvent(flowEvent)
            
        case let .selected(selected):
            return .selected(selected?.equatableProjection)
        }
    }
    
    enum EquatableProjection: Equatable {
        
        case flowEvent(FlowEvent<Status>)
        case selected(PayHubFlowItem<Exchange, Latest, Templates>.EquatableProjection?)
    }
}

