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

private typealias Domain = PaymentsTransfersPersonalDomain

extension RootViewModelFactory {
    
    @inlinable
    func makePaymentsTransfersPersonal(
        nanoServices: PaymentsTransfersPersonalNanoServices
    ) -> PaymentsTransfersPersonalDomain.Binder {
        
        // MARK: - CategoryPicker
        
        let categoryPicker = makeCategoryPickerSection(
            nanoServices: nanoServices
        )
        
        // MARK: - OperationPicker
        
        let operationPicker = makeOperationPicker(nanoServices: nanoServices)
        
        // MARK: - Transfers
        
        typealias TransfersDomain = PaymentsTransfersPersonalTransfersDomain
        
        let transfers = makeTransfers(
            buttonTypes: TransfersDomain.ButtonType.allCases,
            makeQRModel: makeQRScannerModel
        )
        
        // MARK: - PaymentsTransfers
        
        let content = Domain.Content(
            categoryPicker: categoryPicker,
            operationPicker: operationPicker,
            transfers: transfers,
            reload: {
                
                categoryPicker.content.event(.reload)
                operationPicker.content.event(.reload)
            }
        )
        
        return compose(
            getNavigation: getPaymentsTransfersPersonalNavigation,
            content: content,
            witnesses: witnesses()
        )
    }
    
    private func witnesses() -> Domain.Witnesses {
        
        return .init(
            emitting: { $0.eventPublisher },
            receiving: { $0.receiving }
        )
    }
}

// MARK: - Content

private extension Domain.Content {
    
    var eventPublisher: AnyPublisher<PaymentsTransfersPersonalSelect, Never> {
        
        Publishers.Merge3(
            categoryPicker.eventPublisher,
            operationPicker.eventPublisher,
            transfers.eventPublisher
        ).eraseToAnyPublisher()
    }
    
    func receiving() {
        
        categoryPicker.receiving()
        operationPicker.receiving()
        transfers.receiving()
    }
}

// MARK: - CategoryPicker

private extension PayHubUI.CategoryPicker {
    
    var eventPublisher: AnyPublisher<PaymentsTransfersPersonalSelect, Never> {
        
        sectionBinder?.eventPublisher ?? Empty().eraseToAnyPublisher()
    }
    
    func receiving() {
        
        sectionBinder?.receiving()
    }
}

private extension CategoryPickerSectionDomain.Binder {
    
    var eventPublisher: AnyPublisher<PaymentsTransfersPersonalSelect, Never> {
        
        flow.$state
            .compactMap { _ in return nil }
            .eraseToAnyPublisher()
    }
    
    func receiving() {
        
        flow.event(.dismiss)
    }
}

// MARK: - OperationPicker

private extension PayHubUI.OperationPicker {
    
    var eventPublisher: AnyPublisher<PaymentsTransfersPersonalSelect, Never> {
        
        operationBinder?.eventPublisher ?? Empty().eraseToAnyPublisher()
    }
    
    func receiving() {
        
        operationBinder?.receiving()
    }
}

private extension OperationPickerDomain.Binder {
    
    var eventPublisher: AnyPublisher<PaymentsTransfersPersonalSelect, Never> {
        
        flow.$state
            .compactMap(\.select)
            .eraseToAnyPublisher()
    }
    
    func receiving() {
        
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
    
    func receiving() {
        
        transfersBinder?.receiving()
    }
}

private extension PaymentsTransfersPersonalTransfersDomain.Binder {
    
    var eventPublisher: AnyPublisher<PaymentsTransfersPersonalSelect, Never> {
        
        flow.$state
            .compactMap { _ in return nil }
            .eraseToAnyPublisher()
    }
    
    func receiving() {
        
        flow.event(.dismiss)
    }
}
