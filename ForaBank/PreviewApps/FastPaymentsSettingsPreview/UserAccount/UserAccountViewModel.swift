//
//  UserAccountViewModel.swift
//  FastPaymentsSettingsPreview
//
//  Created by Igor Malyarov on 11.01.2024.
//

import Combine
import Foundation

final class UserAccountViewModel: ObservableObject {
    
    @Published /*private(set)*/ var route: Route
    
    private let factory: Factory
    private var cancellables = Set<AnyCancellable>()
    
    init(
        route: Route = .init(),
        factory: Factory
    ) {
        self.route = route
        self.factory = factory
        
        $route.map(\.loader)
            .sink {
                
                print("## loader sink: \(String(describing: $0))")
            }
            .store(in: &cancellables)
    }
}

extension UserAccountViewModel {
    
    func openFastPaymentsSettings() {
        
        let viewModel = factory.makeFastPaymentsSettingsViewModel()
        bind(viewModel)
        route.destination = .fastPaymentsSettings(viewModel)
    }
    
    private func bind(_ viewModel: FastPaymentsSettingsViewModel) {
        
        viewModel.$state
            .compactMap(\.?.inflight)
            .sink { [weak self] in
                
                self?.route.loader = $0
                print("## sink: \($0) | \(String(describing: self?.route.loader))")
            }
            .store(in: &cancellables)
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
