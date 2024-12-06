//
//  QRFailedViewModelWrapper.swift
//  Vortex
//
//  Created by Igor Malyarov on 12.11.2024.
//

import Combine
import CombineSchedulers
import Foundation

final class QRFailedViewModelWrapper: ObservableObject {
    
    @Published private(set) var navigation: Navigation?
    
    private let navigationSubject: PassthroughSubject<Navigation?, Never>
    let qrFailedViewModel: QRFailedViewModel
    
    init(
        model: Model,
        qrCode: QRCode?,
        scheduler: AnySchedulerOf<DispatchQueue> = .main
    ) {
        let navigationSubject = PassthroughSubject<Navigation?, Never>()
        
        qrFailedViewModel = .init(
            model: model,
            addCompanyAction: { navigationSubject.send(.outside(.chat))},
            requisitsAction: {
                
                let paymentsViewModel: PaymentsViewModel
                switch qrCode {
                case .none:
                    paymentsViewModel = .init(
                        model,
                        service: .requisites,
                        closeAction: { navigationSubject.send(nil) }
                    )
                    
                case let .some(qrCode):
                    paymentsViewModel = .init(
                        source: .requisites(qrCode: qrCode),
                        model: model,
                        closeAction: { navigationSubject.send(nil) }
                    )
                }
                
                let cancellable = paymentsViewModel.action
                    .compactMap { $0 as? PaymentsViewModelAction.ScanQrCode }
                    .sink { _ in navigationSubject.send(.outside(.scanQR)) }
                
                let state = Navigation.destination(.init(
                    model: paymentsViewModel,
                    cancellable: cancellable
                ))
                navigationSubject.send(state)
            }
        )
        
        self.navigationSubject = navigationSubject
        
        navigationSubject
            .receive(on: scheduler)
            .assign(to: &$navigation)
    }
    
    func dismiss() {
        
        navigationSubject.send(nil)
    }
    
    enum Navigation {
        
        case outside(Outside)
        case destination(Node<PaymentsViewModel>)
        
        enum Outside {
            
            case chat, scanQR
        }
    }
}
