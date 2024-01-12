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
    @Published private(set) var informer: Informer?
    
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
                
                self?.route.modal = .fpsAlert(.ok(
                    message: $0,
                    primaryAction: {
                        
                        self?.resetModal()
                        viewModel.event(.resetError)
                    }
                ))
            }
            .store(in: &cancellables)
        
        viewModel.$state
            .compactMap(\.?.finalAlertMessage)
            .sink { [weak self] in
                
                self?.route.modal = .fpsAlert(.ok(
                    message: $0,
                    primaryAction: { self?.resetRoute() }
                ))
            }
            .store(in: &cancellables)
        
        viewModel.$state
            .compactMap(\.?.informer)
            .sink { [weak self] informer in
                
                self?.informer = .init(text: "Ошибка изменения настроек СБП.\nПопробуйте позже.")
                
                DispatchQueue.main.asyncAfter(
                    deadline: .now() + 2
                ) { [weak self] in
                    
                    self?.informer = nil
                    viewModel.event(.resetError)
                }
            }
            .store(in: &cancellables)
    }
}

private extension AlertViewModel {
    
    static func ok(
        message: String? = nil,
        primaryAction: @escaping () -> Void
    ) -> Self {
        
        self.init(
            message: message,
            primaryButton: .init(
                type: .default,
                title: "OK",
                action: primaryAction
            )
        )
    }
}

private extension FastPaymentsSettingsViewModel.State {
    
    var alertMessage: String? {
        
        switch error {
            
        case let .serverError(message):
            return message
            
        case .connectivityError:
            return "Превышено время ожидания. Попробуйте позже"
            
        default:
            return nil
        }
    }
    
    var finalAlertMessage: String? {
        
        switch contractConsentAndDefault {
            
        case let .serverError(message):
            return message
            
        case .connectivityError:
            return "Превышено время ожидания. Попробуйте позже"

        default:
            return nil
        }
    }
    
    var informer: Void? {
        
        switch error {
            
        case .updateFailure:
            return ()

        default:
            return nil
        }
    }
}

extension UserAccountViewModel {
    
    func resetRoute() {
        
        DispatchQueue.main.async { [weak self] in
         
            self?.route = .init()
        }
    }
    
    func resetDestination() {
        
        DispatchQueue.main.async { [weak self] in
         
            self?.route.destination = nil
        }
    }
    
    func resetModal() {
        
        DispatchQueue.main.async { [weak self] in
         
            self?.route.modal = nil
        }
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
            case fpsAlert(AlertViewModel)
            
            var alert: AlertViewModel? {
                
                if case let .alert(alert) = self {
                    return alert
                } else {
                    return nil
                }
            }

            var fpsAlert: AlertViewModel? {
                
                if case let .fpsAlert(fpsAlert) = self {
                    return fpsAlert
                } else {
                    return nil
                }
            }
        }
    }
    
    struct Informer {
        
        let text: String
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
