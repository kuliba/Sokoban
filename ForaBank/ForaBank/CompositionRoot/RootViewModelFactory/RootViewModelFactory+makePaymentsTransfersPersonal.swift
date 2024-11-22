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
    
    func makePaymentsTransfersPersonal(
        nanoServices: PaymentsTransfersPersonalNanoServices
    ) -> PaymentsTransfersPersonal {
        
        // MARK: - CategoryPicker
        
        let categoryPicker = makeCategoryPickerSection(
            nanoServices: nanoServices
        )
        
        // MARK: - OperationPicker
        
        let operationPicker = makeOperationPicker(nanoServices: nanoServices)
        
        // MARK: - Toolbar
        
        let toolbar = makePaymentsTransfersPersonalToolbar()
        
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
            toolbar: toolbar,
            transfers: transfers,
            reload: {
                
                categoryPicker.content.event(.reload)
                operationPicker.content.event(.reload)
            }
        )
        
        return compose(
            getNavigation: { select, notify, completion in
                
                
            },
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

extension Domain.Content {
    
    var eventPublisher: AnyPublisher<PaymentsTransfersPersonalSelect, Never> {
        
        Publishers.Merge4(
            categoryPicker.eventPublisher,
            operationPicker.eventPublisher,
            toolbar.eventPublisher,
            transfers.eventPublisher
        ).eraseToAnyPublisher()
    }
    
    func receiving() {
        
        categoryPicker.receiving()
        operationPicker.receiving()
        toolbar.receiving()
        transfers.receiving()
    }
}

// MARK: - CategoryPicker

extension PayHubUI.CategoryPicker {
    
    var eventPublisher: AnyPublisher<PaymentsTransfersPersonalSelect, Never> {
        
        sectionBinder?.eventPublisher ?? Empty().eraseToAnyPublisher()
    }
    
    func receiving() {
        
        sectionBinder?.receiving()
    }
}

extension CategoryPickerSectionDomain.Binder {
    
    var eventPublisher: AnyPublisher<PaymentsTransfersPersonalSelect, Never> {
        
        flow.$state
            .compactMap { _ in return nil }
            .eraseToAnyPublisher()
    }
    
    func receiving() {
        
        content.event(.select(nil))
    }
}

// MARK: - OperationPicker

extension PayHubUI.OperationPicker {
    
    var eventPublisher: AnyPublisher<PaymentsTransfersPersonalSelect, Never> {
        
        operationBinder?.eventPublisher ?? Empty().eraseToAnyPublisher()
    }
    
    func receiving() {
        
        operationBinder?.receiving()
    }
}

extension OperationPickerBinder {
    
    var eventPublisher: AnyPublisher<PaymentsTransfersPersonalSelect, Never> {
        
        flow.$state
            .compactMap { _ in return nil }
            .eraseToAnyPublisher()
    }
    
    func receiving() {
        
        content.event(.select(nil))
    }
}

// MARK: - PaymentsTransfersPersonalToolbar

extension PayHubUI.PaymentsTransfersPersonalToolbar {
    
    var eventPublisher: AnyPublisher<PaymentsTransfersPersonalSelect, Never> {
        
        toolbarBinder?.eventPublisher ?? Empty().eraseToAnyPublisher()
    }
    
    func receiving() {
        
        toolbarBinder?.receiving()
    }
}

extension PaymentsTransfersPersonalToolbarDomain.Binder {
    
    var eventPublisher: AnyPublisher<PaymentsTransfersPersonalSelect, Never> {
        
        flow.$state
            .compactMap { _ in return nil }
            .eraseToAnyPublisher()
    }
    
    func receiving() {
        
        content.event(.select(nil))
    }
}

// MARK: - TransfersPicker

extension PayHubUI.TransfersPicker {
    
    var eventPublisher: AnyPublisher<PaymentsTransfersPersonalSelect, Never> {
        
        transfersBinder?.eventPublisher ?? Empty().eraseToAnyPublisher()
    }
    
    func receiving() {
        
        transfersBinder?.receiving()
    }
}

extension PaymentsTransfersPersonalTransfersDomain.Binder {
    
    var eventPublisher: AnyPublisher<PaymentsTransfersPersonalSelect, Never> {
        
        flow.$state
            .compactMap { _ in return nil }
            .eraseToAnyPublisher()
    }
    
    func receiving() {
        
        content.event(.select(nil))
    }
}
