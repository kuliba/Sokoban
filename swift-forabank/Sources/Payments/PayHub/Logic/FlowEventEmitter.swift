//
//  FlowEventEmitter.swift
//
//
//  Created by Igor Malyarov on 15.08.2024.
//

import Combine

public protocol FlowEventEmitter<Status> {
    
    associatedtype Status
    
    var eventPublisher: AnyPublisher<FlowEvent<Status>, Never> { get }
}

public struct FlowEvent<Status> {
    
    public let isLoading: Bool
    public let status: Status?
    
    public init(
        isLoading: Bool,
        status: Status?
    ) {
        self.isLoading = isLoading
        self.status = status
    }
}

extension FlowEvent: Equatable where Status: Equatable {}
