//
//  ProductProfileNavigation+State.swift
//
//
//  Created by Andryusina Nataly on 05.02.2024.
//

import UIPrimitives
import ProductProfileComponents
import Combine

public extension ProductProfileNavigation {
    
    struct State: Equatable {
        
        public var modal: ProductProfileRoute?
        public var destination: ProductDetailsRoute?
        public var alert: AlertModelOf<Event>?
        public var informer: String?

        public init(
            modal: ProductProfileRoute? = nil,
            destination: ProductDetailsRoute? = nil,
            alert: AlertModelOf<Event>? = nil,
            informer: String? = nil
        ) {
            self.modal = modal
            self.destination = destination
            self.alert = alert
            self.informer = informer
        }
    }
}

extension ProductProfileNavigation.State.ProductDetailsRoute: Hashable {
    
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.id == rhs.id
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

public extension ProductProfileNavigation.State {
    
    enum CGDestination: Equatable, Identifiable {
        
        case showAccountInfoPanel(AccountInfoPanelViewModel, AnyCancellable)
        case showProductDetails(ProductDetailsViewModel, AnyCancellable)
        case showPanel(CardGuardianViewModel, AnyCancellable)
        case showTopUpCardPanel(TopUpCardViewModel, AnyCancellable)

        public var id: Case {
            
            switch self {
            case .showAccountInfoPanel:
                return .showAccountInfoPanel
            case .showProductDetails:
                return .showProductDetails
            case .showPanel:
                return .showPanel
            case .showTopUpCardPanel:
                return .showTopUpCardPanel
            }
        }
        
        public enum Case {
            
            case showAccountInfoPanel
            case showProductDetails
            case showPanel
            case showTopUpCardPanel
        }
    }
}

// MARK: - Hashable Conformance

extension ProductProfileNavigation.State.CGDestination: Hashable {
    
    public static func == (lhs: Self, rhs: Self) -> Bool {
        
        switch (lhs, rhs) {
        case let (.showAccountInfoPanel(lhs, _), .showAccountInfoPanel(rhs, _)):
            return ObjectIdentifier(lhs) == ObjectIdentifier(rhs)
        case let (.showProductDetails(lhs, _), .showProductDetails(rhs, _)):
            return ObjectIdentifier(lhs) == ObjectIdentifier(rhs)
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
        case let .showAccountInfoPanel(viewModel, _):
            hasher.combine(ObjectIdentifier(viewModel))
        case let .showProductDetails(viewModel, _):
            hasher.combine(ObjectIdentifier(viewModel))
        case let .showPanel(viewModel, _):
            hasher.combine(ObjectIdentifier(viewModel))
        case let .showTopUpCardPanel(viewModel, _):
            hasher.combine(ObjectIdentifier(viewModel))
        }
    }
}

