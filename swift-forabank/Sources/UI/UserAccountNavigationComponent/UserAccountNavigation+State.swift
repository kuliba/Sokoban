//
//  UserAccountNavigation+State.swift
//
//
//  Created by Igor Malyarov on 28.01.2024.
//

import C2BSubscriptionUI
import Combine
import FastPaymentsSettings
import OTPInputComponent
import RxViewModel
import UIPrimitives

public extension UserAccountNavigation {
    
    struct State: Equatable {
        
        public var destination: FPSRoute?
        public var alert: AlertModelOf<Event>?
        public var isLoading: Bool
        public var informer: String?
        
        public init(
            destination: FPSRoute? = nil,
            alert: AlertModelOf<Event>? = nil,
            isLoading: Bool = false,
            informer: String? = nil
        ) {
            self.destination = destination
            self.alert = alert
            self.isLoading = isLoading
            self.informer = informer
        }
    }
}

public extension UserAccountNavigation.State {
    
    typealias Event = UserAccountNavigation.Event
    
    typealias FastPaymentsSettingsViewModel = RxViewModel<FastPaymentsSettingsState, FastPaymentsSettingsEvent, FastPaymentsSettingsEffect>
    
    typealias FPSRoute = GenericRoute<FastPaymentsSettingsViewModel, UserAccountNavigation.State.FPSDestination, Never, AlertModelOf<UserAccountNavigation.Event>>
}

public extension UserAccountNavigation.State {
    
    
    enum FPSDestination: Equatable, Identifiable {
        
#warning("remove optionality: change `AnyCancellable?` to `AnyCancellable` after replacing `GetC2BSubResponse` to view model as associated type")
        case c2BSub(GetC2BSubResponse, AnyCancellable?)
        case confirmSetBankDefault(TimedOTPInputViewModel, AnyCancellable)//(phoneNumberMask: String)
        
        public var id: Case {
            
            switch self {
            case .c2BSub: 
                return .c2BSub
                
            case .confirmSetBankDefault:
                return .confirmSetBankDefault
            }
        }
        
        public enum Case {
            
            case c2BSub
            case confirmSetBankDefault
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

extension UserAccountNavigation.State.FPSDestination: Hashable {
    
    public static func == (lhs: Self, rhs: Self) -> Bool {
        
        switch (lhs, rhs) {
        case let (.confirmSetBankDefault(lhs, _), .confirmSetBankDefault(rhs, _)):
            return ObjectIdentifier(lhs) == ObjectIdentifier(rhs)
            
        case let (.c2BSub(lhs, _), .c2BSub(rhs, _)):
            return lhs == rhs
            
        default:
            return false
        }
    }
    
    public func hash(into hasher: inout Hasher) {
        
        switch self {
        case let .confirmSetBankDefault(viewModel, _):
            hasher.combine(ObjectIdentifier(viewModel))
            
        case let .c2BSub(getC2BSubResponse, _):
            hasher.combine(getC2BSubResponse)
        }
    }
}

extension GetC2BSubResponse: Hashable {
    
    public func hash(into hasher: inout Hasher) {
        
        switch details {
        case .empty:
            hasher.combine(0)
        
        case let .list(list):
            hasher.combine(list.map(\.id))
        }
    }
}
