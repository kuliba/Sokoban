//
//  UserAccountNavigation+State.swift
//
//
//  Created by Igor Malyarov on 28.01.2024.
//

import Combine
import FastPaymentsSettings
import OTPInputComponent
import RxViewModel
import UIPrimitives

public extension UserAccountNavigation {
    
    struct State: Equatable {
        
        public var destination: Destination?
        public var alert: Alert?
        public var isLoading: Bool
        
        public init(
            destination: Destination? = nil,
            modal: Alert? = nil,
            isLoading: Bool = false
        ) {
            self.destination = destination
            self.alert = modal
            self.isLoading = isLoading
        }
    }
}

public extension UserAccountNavigation.State {
    
    typealias Event = UserAccountNavigation.Event
    
    enum Destination: Equatable {
        
        case fastPaymentsSettings(FPSRoute)
    }
    
    enum Alert: Equatable {
        
        case alert(AlertModelOf<Event>)
    }
}

public extension UserAccountNavigation.State.Destination {
    
    typealias FastPaymentsSettingsViewModel = RxViewModel<FastPaymentsSettingsState, FastPaymentsSettingsEvent, FastPaymentsSettingsEffect>
    
    typealias FPSRoute = GenericRoute<FastPaymentsSettingsViewModel, UserAccountNavigation.State.Destination.FPSDestination, Never, AlertModelOf<UserAccountNavigation.Event>>
    
    enum FPSDestination: Equatable {
        
        case confirmSetBankDefault(TimedOTPInputViewModel, AnyCancellable)//(phoneNumberMask: String)
#warning("change `AnyCancellable?` to `AnyCancellable` after replacing `GetC2BSubResponse` to view model as associated type")
        case c2BSub(GetC2BSubResponse, AnyCancellable?)
    }
}

// MARK: - Helpers

public extension UserAccountNavigation.State {
    
    var fpsRoute: UserAccountNavigation.State.Destination.FPSRoute? {
        
        get {
            guard case let .fastPaymentsSettings(fpsRoute) = destination
            else { return nil }
            
            return fpsRoute
        }
        
        set(newValue) {
            guard case .fastPaymentsSettings = destination
            else { return }
            
            self.destination = newValue.map(Destination.fastPaymentsSettings)
        }
    }
}

// MAKR: - Hashable Conformance

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

extension UserAccountNavigation.State.Destination: Hashable {
    
    public static func == (lhs: Self, rhs: Self) -> Bool {
        
        switch (lhs, rhs) {
        case let (.fastPaymentsSettings(lhs), .fastPaymentsSettings(rhs)):
            return lhs.hashValue == rhs.hashValue
        }
    }
    
    public func hash(into hasher: inout Hasher) {
        switch self {
        case let .fastPaymentsSettings(route):
            hasher.combine(route.hashValue)
        }
    }
}

extension UserAccountNavigation.State.Destination.FPSDestination: Hashable {
    
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
