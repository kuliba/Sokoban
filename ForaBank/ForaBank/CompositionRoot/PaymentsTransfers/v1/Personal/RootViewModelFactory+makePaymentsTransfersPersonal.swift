//
//  RootViewModelFactory+makePaymentsTransfersPersonal.swift
//  ForaBank
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

// MARK: - Content

private extension PaymentsTransfersPersonalDomain.Content {
    
    var eventPublisher: AnyPublisher<PaymentsTransfersPersonalSelect, Never> {
        
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
    
    var eventPublisher: AnyPublisher<PaymentsTransfersPersonalSelect, Never> {
        
        sectionBinder?.eventPublisher ?? Empty().eraseToAnyPublisher()
    }
    
    func dismiss() {
        
        sectionBinder?.dismiss()
    }
}

private extension CategoryPickerSectionDomain.Binder {
    
    var eventPublisher: AnyPublisher<PaymentsTransfersPersonalSelect, Never> {
        
        flow.$state
            .compactMap { _ in return nil }
            .eraseToAnyPublisher()
    }
    
    func dismiss() {
        
        flow.event(.dismiss)
    }
}

// MARK: - OperationPicker

private extension PayHubUI.OperationPicker {
    
    var eventPublisher: AnyPublisher<PaymentsTransfersPersonalSelect, Never> {
        
        operationBinder?.eventPublisher ?? Empty().eraseToAnyPublisher()
    }
    
    func dismiss() {
        
        operationBinder?.dismiss()
    }
}

private extension OperationPickerDomain.Binder {
    
    var eventPublisher: AnyPublisher<PaymentsTransfersPersonalSelect, Never> {
        
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
        case .templates: return .outside(.templates)
        default:         return nil
        }
    }
}

// MARK: - TransfersPicker

private extension PayHubUI.TransfersPicker {
    
    var eventPublisher: AnyPublisher<PaymentsTransfersPersonalSelect, Never> {
        
        transfersBinder?.eventPublisher ?? Empty().eraseToAnyPublisher()
    }
    
    func dismiss() {
        
        transfersBinder?.dismiss()
    }
}

private extension PaymentsTransfersPersonalTransfersDomain.Binder {
    
    var eventPublisher: AnyPublisher<PaymentsTransfersPersonalSelect, Never> {
        
        flow.$state
            .compactMap { _ in return nil }
            .eraseToAnyPublisher()
    }
    
    func dismiss() {
        
        flow.event(.dismiss)
    }
}
