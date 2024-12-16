//
//  RootViewModelFactory+makePaymentsTransfersPersonal.swift
//  Vortex
//
//  Created by Igor Malyarov on 20.09.2024.
//

import Combine
import CombineSchedulers
import Foundation
import PayHub
import PayHubUI

extension RootViewModelFactory {
    
    @inlinable
    func makePaymentsTransfersPersonal(
        nanoServices: PaymentsTransfersPersonalNanoServices
    ) -> PaymentsTransfersPersonalDomain.Binder {
        
        return compose(
            getNavigation: getPaymentsTransfersPersonalNavigation,
            content: makePaymentsTransfersPersonalContent(nanoServices),
            witnesses: .init(
                emitting: { $0.eventPublisher },
                dismissing: { $0.dismiss }
            )
        )
    }
}

private typealias EventPublisher = AnyPublisher<PaymentsTransfersPersonalSelect, Never>

// MARK: - Content

private extension PaymentsTransfersPersonalDomain.Content {
    
    var eventPublisher: EventPublisher {
        
        Publishers.Merge3(
            categoryPicker.eventPublisher,
            operationPicker.eventPublisher,
            transfers.eventPublisher
        ).eraseToAnyPublisher()
    }
    
    func dismiss() {
        
        categoryPicker.dismiss()
        operationPicker.dismiss()
        transfers.dismiss()
    }
}

// MARK: - CategoryPicker

private extension PayHubUI.CategoryPicker {
    
    var eventPublisher: EventPublisher {
        
        sectionBinder?.eventPublisher ?? Empty().eraseToAnyPublisher()
    }
    
    func dismiss() {
        
        sectionBinder?.dismiss()
    }
}

private extension CategoryPickerSectionDomain.Binder {
    
    var eventPublisher: EventPublisher {
        
        flow.$state
            .compactMap(\.select)
            .eraseToAnyPublisher()
    }
    
    func dismiss() {
        
        flow.event(.dismiss)
    }
}

private extension FlowState<SelectedCategoryNavigation> {
    
    var select: PaymentsTransfersPersonalSelect? {
        
        switch navigation {
        case let .paymentFlow(paymentFlow):
            switch paymentFlow {
            case .mobile, .taxAndStateServices, .transport:
                return nil
                
            case .qr(()):
                return .scanQR
                
            case let .standard(category):
                return .standardPayment(category.type)
            }
            
        default:
            return nil
        }
    }
}

// MARK: - OperationPicker

private extension PayHubUI.OperationPicker {
    
    var eventPublisher: EventPublisher {
        
        operationBinder?.eventPublisher ?? Empty().eraseToAnyPublisher()
    }
    
    func dismiss() {
        
        operationBinder?.dismiss()
    }
}

private extension OperationPickerDomain.Binder {
    
    var eventPublisher: EventPublisher {
        
        flow.$state
            .compactMap(\.select)
            .eraseToAnyPublisher()
    }
    
    func dismiss() {
        
        flow.event(.dismiss)
    }
}

private extension OperationPickerDomain.FlowDomain.State {
    
    var select: PaymentsTransfersPersonalSelect? {
        
        switch navigation {
        case .none, .exchange, .latest:
            return nil
            
        case let .status(status):
            switch status {
            case .main:
                return .main
                
            case .exchangeFailure:
                return nil
            }
            
        case .templates:
            return .templates
        }
    }
}

// MARK: - TransfersPicker

private extension PayHubUI.TransfersPicker {
    
    var eventPublisher: EventPublisher {
        
        transfersBinder?.eventPublisher ?? Empty().eraseToAnyPublisher()
    }
    
    func dismiss() {
        
        transfersBinder?.dismiss()
    }
}

private extension PaymentsTransfersPersonalTransfersDomain.Binder {
    
    var eventPublisher: EventPublisher {
        
        flow.$state
            .compactMap { _ in return nil }
            .eraseToAnyPublisher()
    }
    
    func dismiss() {
        
        flow.event(.dismiss)
    }
}
