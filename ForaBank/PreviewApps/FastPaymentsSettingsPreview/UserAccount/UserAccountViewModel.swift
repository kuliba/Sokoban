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
        
//        $route
//            .sink { print($0) }
//            .store(in: &cancellables)
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
        
#warning("combine multiple pipelines into one, extract composed sink into helpers")
        
        viewModel.$state
            .compactMap(\.?.isInflight)
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
                ) { [weak self] in self?.informer = nil }
            }
            .store(in: &cancellables)
        
        viewModel.$state
            .compactMap(\.?.missingProduct)
            .sink { [weak self] in
                
                self?.route.modal = .fpsAlert(.ok(
                    title: "Сервис не доступен",
                    message: "Для подключения договора СБП у Вас должен быть подходящий продукт",
                    primaryAction: {
                        
                        self?.resetRoute()
                        viewModel.event(.resetError)
                    }
                ))
            }
            .store(in: &cancellables)
        
        viewModel.$state
            .compactMap(\.?.setBankDefault)
            .sink { [weak self] in
                
                self?.route.modal = .fpsAlert(.init(
                    title: "Внимание",
                    message: "Фора-банк будет выбран банком по умолчанию",
                    primaryButton: .init(
                        type: .default,
                        title: "OK",
                        action: {
                            
                            self?.resetModal()
                            viewModel.event(.resetError)
                            viewModel.event(.prepareSetBankDefault)
                        }),
                    secondaryButton: .init(
                        type: .cancel,
                        title: "Отмена",
                        action: {
                            
                            viewModel.event(.resetError)
                            self?.resetModal()
                        }
                    )
                ))
            }
            .store(in: &cancellables)
        
        viewModel.$state
            .compactMap(\.?.confirmSetBankDefault)
            .sink { [weak self] in
                
                viewModel.event(.resetError)
                self?.route.fpsDestination = .confirmSetBankDefault
            }
            .store(in: &cancellables)
    }
}

private extension AlertViewModel {
    
    static func ok(
        title: String = "",
        message: String? = nil,
        primaryAction: @escaping () -> Void
    ) -> Self {
        
        self.init(
            title: title,
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
        
        switch alert {
        case let .serverError(message):
            return message
            
        case .connectivityError:
            return "Превышено время ожидания. Попробуйте позже"
            
        default:
            return nil
        }
    }
    
    var finalAlertMessage: String? {
        
        switch userPaymentSettings {
        case let .failure(.serverError(message)):
            return message
            
        case .failure(.connectivityError):
            return "Превышено время ожидания. Попробуйте позже"

        default:
            return nil
        }
    }
    
    var informer: Void? {
        
        switch alert {
        case .updateContractFailure:
            return ()

        default:
            return nil
        }
    }
    
    var missingProduct: Void? {
        
        switch alert {
        case .missingProduct:
            return ()

        default:
            return nil
        }
    }
    
    var setBankDefault: Void? {
        
        switch alert {
        case .setBankDefault:
            return ()

        default:
            return nil
        }
    }
    
    var confirmSetBankDefault: Void? {
        
        switch alert {
        case .confirmSetBankDefault:
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
    
    func resetFPSDestination() {
        
//        DispatchQueue.main.async { [weak self] in
         
            /*self?.*/route.fpsDestination = nil
//        }
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
        var fpsDestination: FPSDestination?
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
        
        enum FPSDestination {
            
            case confirmSetBankDefault//(phoneNumberMask: String)
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
