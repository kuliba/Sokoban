//
//  ProductProfileNavigation+State.swift
//
//
//  Created by Andryusina Nataly on 05.02.2024.
//

import UIPrimitives
import CardGuardianUI
import Combine
import TopUpCardUI

public extension ProductProfileNavigation {
    
    struct State: Equatable {
        
        public var modal: Route?
        public var alert: AlertModelOf<Event>?

        public init(
            modal: Route? = nil,
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
        case showTopUpCardPanel(TopUpCardViewModel, AnyCancellable)

        public var id: Case {
            
            switch self {
            case .showPanel:
                return .showPanel
            case .showTopUpCardPanel:
                return .showTopUpCardPanel
            }
        }
        
        public enum Case {
            
            case showPanel
            case showTopUpCardPanel
        }
    }
}

// MARK: - Hashable Conformance

extension ProductProfileNavigation.State.CGDestination: Hashable {
    
    public static func == (lhs: Self, rhs: Self) -> Bool {
        
        switch (lhs, rhs) {
        case let (.showPanel(lhs, _), .showPanel(rhs, _)):
            return ObjectIdentifier(lhs) == ObjectIdentifier(rhs)
        case let (.showTopUpCardPanel(lhs, _), .showTopUpCardPanel(rhs, _)):
            return ObjectIdentifier(lhs) == ObjectIdentifier(rhs)
        default:
            return false
        }
    }
    
    public func hash(into hasher: inout Hasher) {
        
        switch self {
        case let .showPanel(viewModel, _):
            hasher.combine(ObjectIdentifier(viewModel))
        case let .showTopUpCardPanel(viewModel, _):
            hasher.combine(ObjectIdentifier(viewModel))

        }
    }
}

