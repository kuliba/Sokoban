//
//  UserAccountViewModel.swift
//  FastPaymentsSettingsPreview
//
//  Created by Igor Malyarov on 11.01.2024.
//

import Combine
import Foundation

final class UserAccountViewModel: ObservableObject {
    
    @Published private(set) var route: Route
    
    private let factory: Factory
    private var cancellables = Set<AnyCancellable>()
    
    init(
        route: Route = .init(),
        factory: Factory
    ) {
        self.route = route
        self.factory = factory
    }
}

// MARK: - Demo Functionality

extension UserAccountViewModel {
    
    func showDemoLoader() {
        
        route.isLoading = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
            
            self?.route.isLoading = false
        }
    }
    
    func showDemoAlert() {
        
        route.modal = .alert(.init(
            title: "Test Alert",
            primaryButton: .init(
                type: .default,
                title: "OK",
                action: resetModal
            )
        ))
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
            .sink { [weak self] in self?.route.isLoading = $0 }
            .store(in: &cancellables)
        
        viewModel.$state
            .compactMap(\.?.alertMessage)
            .sink { [weak self] in
                
                self?.route.modal = .alert(.init(
                    message: $0,
                    primaryButton: .init(
                        type: .default,
                        title: "OK",
                        action: { self?.resetModal() }
                    )
                ))
            }
            .store(in: &cancellables)
    }
}

private extension FastPaymentsSettingsViewModel.State {
    
    var alertMessage: String? {
        
        switch contractConsentAndDefault {
            
        case let .serverError(message):
            return message
            
        case .connectivityError:
            return "Превышено время ожидания. Попробуйте позже"
            
        default:
            return nil
        }
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
        var isLoading = false
        
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
