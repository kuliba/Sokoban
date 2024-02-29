//
//  ProductProfileNavigation+State.swift
//
//
//  Created by Andryusina Nataly on 05.02.2024.
//

import UIPrimitives
import CardGuardianUI
import Combine

public extension ProductProfileNavigation {
    
    struct State: Equatable {
        
        public var modal: ProductProfileRoute?
        public var alert: AlertModelOf<Event>?

        public init(
            modal: ProductProfileRoute? = nil,
            alert: AlertModelOf<Event>? = nil
        ) {
            self.modal = modal
            self.alert = alert
        }
    }
}

public extension ProductProfileNavigation.State {
    
    enum CGDestination: Equatable, Identifiable {
        
        case showPanel(CardGuardianViewModel, AnyCancellable)
        
        public var id: Case {
            
            switch self {
            case .showPanel:
                return .showPanel
            }
        }
        
        public enum Case {
            
            case showPanel
        }
    }
}

// MARK: - Hashable Conformance

extension ProductProfileNavigation.State.CGDestination: Hashable {
    
    public static func == (lhs: Self, rhs: Self) -> Bool {
        
        switch (lhs, rhs) {
        case let (.showPanel(lhs, _), .showPanel(rhs, _)):
            return ObjectIdentifier(lhs) == ObjectIdentifier(rhs)
        }
    }
    
    public func hash(into hasher: inout Hasher) {
        
        switch self {
        case let .showPanel(viewModel, _):
            hasher.combine(ObjectIdentifier(viewModel))
        }
    }
}

