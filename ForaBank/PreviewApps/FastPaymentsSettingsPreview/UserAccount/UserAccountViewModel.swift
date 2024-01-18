//
//  UserAccountViewModel.swift
//  FastPaymentsSettingsPreview
//
//  Created by Igor Malyarov on 11.01.2024.
//

import Combine
import FastPaymentsSettings
import Foundation

final class UserAccountViewModel: ObservableObject {
    
    @Published private(set) var route: Route
    
    let informer: InformerViewModel
    
    private let factory: Factory
    private var cancellables = Set<AnyCancellable>()
    
    init(
        route: Route = .init(),
        informer: InformerViewModel = .init(),
        factory: Factory
    ) {
        self.route = route
        self.informer = informer
        self.factory = factory
        
        //        $route
        //            .map(\.isLoading)
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
            message: "Long alert message here.",
            primaryButton: .init(
                type: .default,
                title: "OK",
                action: dismissModal
            )
        ))
    }
    
    func showDemoInformer() {
        
        informer.set(text: "Demo Informer Text.")
    }
}

// MARK: - Confirm with OTP

extension UserAccountViewModel {
    
    func handleOTPResult(
        _ result: ConfirmWithOTPResult
    ) {
        dismissFPSDestination()
        fpsViewModel?.event(.resetStatus)
        
        switch result {
        case .success:
            informer.set(text: "Банк по умолчанию установлен")
            fpsViewModel?.event(.confirmSetBankDefault)
            
        case .incorrectCode:
            informer.set(text: "Банк по умолчанию не установлен")
            
        case let .serverError(message):
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self] in
                
                self?.route.modal = .fpsAlert(.ok(
                    title: "Ошибка",
                    message: message,
                    primaryAction: { [weak self] in self?.dismissModal() }
                ))
            }
            
        case .connectivityError:
            informer.set(text: "Ошибка изменения настроек СБП.\nПопробуйте позже.")
        }
    }
}

private extension UserAccountViewModel {
    
    var fpsViewModel: FastPaymentsSettingsViewModel? {
        
        switch route.destination {
        case let .fastPaymentsSettings(fpsViewModel):
            return fpsViewModel
            
        default:
            return nil
        }
    }
}

// MARK: - Fast Payments Settings

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
                        
                        self?.dismissModal()
                        viewModel.event(.resetStatus)
                    }
                ))
            }
            .store(in: &cancellables)
        
        viewModel.$state
            .compactMap(\.?.finalAlertMessage)
            .sink { [weak self] in
                
                self?.route.modal = .fpsAlert(.ok(
                    message: $0,
                    primaryAction: {
                        
                        self?.resetRoute()
#warning("resetStatus is needed?")
                        // viewModel.event(.resetStatus)
                    }
                ))
            }
            .store(in: &cancellables)
        
        viewModel.$state
            .compactMap(\.?.informer)
            .sink { [weak self] informer in
                
                self?.informer.set(text: "Ошибка изменения настроек СБП.\nПопробуйте позже.")
#warning("resetStatus is needed?")
                // viewModel.event(.resetStatus)
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
                        viewModel.event(.resetStatus)
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
                            
                            self?.dismissModal()
                            viewModel.event(.resetStatus)
                            viewModel.event(.prepareSetBankDefault)
                        }),
                    secondaryButton: .init(
                        type: .cancel,
                        title: "Отмена",
                        action: {
                            
                            self?.dismissModal()
                            viewModel.event(.resetStatus)
                        }
                    )
                ))
            }
            .store(in: &cancellables)
        
        viewModel.$state
            .compactMap(\.?.confirmSetBankDefault)
            .sink { [weak self] in
                
                viewModel.event(.resetStatus)
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

private extension FastPaymentsSettingsState {
    
    var alertMessage: String? {
        
        switch status {
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
        
        switch status {
        case .updateContractFailure:
            return ()
            
        default:
            return nil
        }
    }
    
    var missingProduct: Void? {
        
        switch status {
        case .missingProduct:
            return ()
            
        default:
            return nil
        }
    }
    
    var setBankDefault: Void? {
        
        switch status {
        case .setBankDefault:
            return ()
            
        default:
            return nil
        }
    }
    
    var confirmSetBankDefault: Void? {
        
        switch status {
        case .confirmSetBankDefault:
#warning("need `phoneNumberMask` from contract!")
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
    
    func dismissDestination() {
        
        DispatchQueue.main.async { [weak self] in
            
            self?.route.destination = nil
        }
    }
    
    func dismissFPSDestination() {
        
        //        DispatchQueue.main.async { [weak self] in
        
        /*self?.*/route.fpsDestination = nil
        //        }
    }
    
    func dismissModal() {
        
        DispatchQueue.main.async { [weak self] in
            
            self?.route.modal = nil
        }
    }
}

extension UserAccountViewModel {
    
    struct Route: Equatable {
        
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
        
        enum Destination: Equatable {
            
            case fastPaymentsSettings(FastPaymentsSettingsViewModel)
        }
        
        enum FPSDestination: Equatable {
            
            case confirmSetBankDefault//(phoneNumberMask: String)
        }
        
        enum Modal: Equatable {
            
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
