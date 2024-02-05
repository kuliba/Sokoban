//
//  ProductProfileNavigation+State.swift
//
//
//  Created by Andryusina Nataly on 05.02.2024.
//

import UIPrimitives
import CardGuardianModule
import Combine

public extension ProductProfileNavigation {
    
    struct State: Equatable {
        
        public var destination: ProductProfileRoute?
        public var alert: AlertModelOf<Event>?
        
        public init(
            destination: ProductProfileRoute? = nil,
            alert: AlertModelOf<Event>? = nil
        ) {
            self.destination = destination
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

extension AlertModel: Hashable
where PrimaryEvent: Equatable,
      SecondaryEvent: Equatable {
    
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.id == rhs.id
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

#warning("delete?")
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

