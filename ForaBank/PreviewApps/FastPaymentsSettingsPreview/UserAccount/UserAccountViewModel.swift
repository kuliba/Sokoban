//
//  UserAccountViewModel.swift
//  FastPaymentsSettingsPreview
//
//  Created by Igor Malyarov on 11.01.2024.
//

import Foundation

final class UserAccountViewModel: ObservableObject {
    
    @Published private(set) var route: Route
    
    private let factory: Factory
    
    init(
        route: Route = .init(),
        factory: Factory
    ) {
        self.route = route
        self.factory = factory
    }
}

extension UserAccountViewModel {
    
    func openFastPaymentsSettings() {
        
        let viewModel = factory.makeFastPaymentsSettingsViewModel()
        route.destination = .fastPaymentsSettings(viewModel)
    }
}

extension UserAccountViewModel {
    
    func resetDestination() {
        
        route.destination = nil
    }
    
    func resetModal() {
        
        route.modal = nil
    }
}

extension UserAccountViewModel {
    
    struct Route {
        
        var destination: Destination?
        var modal: Modal?
        var loader = false
        
        init(
            destination: Destination? = nil,
            modal: Modal? = nil
        ) {
            self.destination = destination
            self.modal = modal
        }
        
        enum Destination {
            
            case fastPaymentsSettings(FastPaymentsSettingsViewModel)
        }
        
        enum Modal {
            
            case alert(AlertViewModel)
            
            var alert: AlertViewModel? {
                
                if case let .alert(alert) = self {
                    return alert
                } else {
                    return nil
                }
            }
        }
    }
}

extension UserAccountViewModel.Route.Destination: Hashable {
    
    static func == (lhs: Self, rhs: Self) -> Bool {
        
        switch (lhs, rhs) {
        case let (.fastPaymentsSettings(lhs), .fastPaymentsSettings(rhs)):
            ObjectIdentifier(lhs) == ObjectIdentifier(rhs)
        }
    }
    
    func hash(into hasher: inout Hasher) {
        switch self {
        case let .fastPaymentsSettings(viewModel):
            hasher.combine(ObjectIdentifier(viewModel))
        }
    }
}
