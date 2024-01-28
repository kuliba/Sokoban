//
//  UserAccountViewModel.Route.swift
//
//
//  Created by Igor Malyarov on 28.01.2024.
//

import Combine
import FastPaymentsSettings
import OTPInputComponent
import UIPrimitives

extension UserAccountViewModel {
    
    struct Route: Equatable {
        
        var destination: Destination?
        var alert: Alert?
        var isLoading: Bool
        
        init(
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

extension UserAccountViewModel.Route {
    
    typealias Event = UserAccountViewModel.Event
    
    enum Destination: Equatable {
        
        case fastPaymentsSettings(FPSRoute)
    }
    
    enum Alert: Equatable {
        
        case alert(AlertModelOf<Event>)
    }
}

extension UserAccountViewModel.Route.Destination {
    
    typealias FPSRoute = GenericRoute<FastPaymentsSettingsViewModel, UserAccountViewModel.State.Destination.FPSDestination, Never, AlertModelOf<UserAccountViewModel.Event>>
    
    enum FPSDestination: Equatable {
        
        case confirmSetBankDefault(TimedOTPInputViewModel, AnyCancellable)//(phoneNumberMask: String)
#warning("change `AnyCancellable?` to `AnyCancellable` after replacing `GetC2BSubResponse` to view model as associated type")
        case c2BSub(GetC2BSubResponse, AnyCancellable?)
    }
}

// MARK: - Helpers

extension UserAccountViewModel.Route {
    
    var fpsRoute: UserAccountViewModel.State.Destination.FPSRoute? {
        
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
    
    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.id == rhs.id
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

extension UserAccountViewModel.State.Destination: Hashable {
    
    static func == (lhs: Self, rhs: Self) -> Bool {
        
        switch (lhs, rhs) {
        case let (.fastPaymentsSettings(lhs), .fastPaymentsSettings(rhs)):
            lhs.hashValue == rhs.hashValue
        }
    }
    
    func hash(into hasher: inout Hasher) {
        switch self {
        case let .fastPaymentsSettings(route):
            hasher.combine(route.hashValue)
        }
    }
}

extension UserAccountViewModel.State.Destination.FPSDestination: Hashable {
    
    static func == (lhs: Self, rhs: Self) -> Bool {
        
        switch (lhs, rhs) {
        case let (.confirmSetBankDefault(lhs, _), .confirmSetBankDefault(rhs, _)):
            return ObjectIdentifier(lhs) == ObjectIdentifier(rhs)
            
        case let (.c2BSub(lhs, _), .c2BSub(rhs, _)):
            return lhs == rhs
            
        default:
            return false
        }
    }
    
    func hash(into hasher: inout Hasher) {
        
        switch self {
        case let .confirmSetBankDefault(viewModel, _):
            hasher.combine(ObjectIdentifier(viewModel))
            
        case let .c2BSub(getC2BSubResponse, _):
            hasher.combine(getC2BSubResponse)
        }
    }
}
