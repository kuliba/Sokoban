//
//  FlowEventEmitter.swift
//  
//
//  Created by Igor Malyarov on 15.08.2024.
//

import Combine

protocol FlowEventEmitter<Status> {
    
    associatedtype Status
    
    var eventPublisher: AnyPublisher<FlowEvent<Status>, Never> { get }
}

struct FlowEvent<Status> {
    
    let isLoading: Bool
    let status: Status?
}

extension FlowEvent: Equatable where Status: Equatable {}
