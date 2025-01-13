//
//  RootViewModelFactory+makePaymentsTransfersPersonal.swift
//  Vortex
//
//  Created by Igor Malyarov on 20.09.2024.
//

import Combine
import CombineSchedulers
import Foundation
import PayHubUI

extension RootViewModelFactory {
    
    @inlinable
    func makePaymentsTransfersPersonal(
    ) -> (PaymentsTransfersPersonalDomain.Binder, () -> Void) {
        
        let nanoServices = composePaymentsTransfersPersonalNanoServices()
        
        let personal = makePaymentsTransfersPersonal(
            nanoServices: nanoServices
        )
        
        let loadCategoriesAndNotifyPicker = {
            
            nanoServices.reloadCategories { [weak personal] categories in
                
                let categoryPicker = personal?.content.categoryPicker.sectionBinder
                
                guard let categoryPicker else {
                    
                    return self.logger.log(level: .error, category: .payments, message: "==== Unknown categoryPicker type \(String(describing: categoryPicker))", file: #file, line: #line)
                }
                
                categoryPicker.content.event(.loaded(categories ?? []))
                
                self.logger.log(level: .info, category: .network, message: "==== Loaded \(categories?.count ?? 0) categories", file: #file, line: #line)
            }
        }
        
        return (personal, loadCategoriesAndNotifyPicker)
    }
    
    @inlinable
    func makePaymentsTransfersPersonal(
        nanoServices: PaymentsTransfersPersonalNanoServices
    ) -> PaymentsTransfersPersonalDomain.Binder {
        
        let content = makePaymentsTransfersPersonalContent(nanoServices)
        
        return composeBinder(
            content: content,
            delayProvider: delayProvider,
            getNavigation: getPaymentsTransfersPersonalNavigation,
            witnesses: .init(emitting: emitting, dismissing: dismissing)
        )
    }
    
    @inlinable
    func delayProvider(
        navigation: PaymentsTransfersPersonalDomain.Navigation
    ) -> Delay {
        
        switch navigation {
        case .byPhoneTransfer: return .milliseconds(100)
        case .main:            return .milliseconds(100)
        case .scanQR:          return .milliseconds(100)
        case .standardPayment: return settings.delay
        case .templates:       return settings.delay
        case .userAccount:     return settings.delay
        }
    }
    
    @inlinable
    func emitting(
        content: PaymentsTransfersPersonalDomain.Content
    ) -> some Publisher<FlowEvent<PaymentsTransfersPersonalDomain.Select, Never>, Never> {
        
        content.eventPublisher
    }
    
    @inlinable
    func dismissing(
        content: PaymentsTransfersPersonalDomain.Content
    ) -> () -> Void {
        
        return { content.dismiss() }
    }
}

private typealias EventPublisher = AnyPublisher<FlowEvent<PaymentsTransfersPersonalSelect, Never>, Never>

// MARK: - Content

extension PaymentsTransfersPersonalDomain.Content {
    
    fileprivate var eventPublisher: EventPublisher {
        
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

private extension CategoryPicker {
    
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
            .map { .select($0) }
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

private extension OperationPicker {
    
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
            .map { .select($0) }
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
            
        case .exchangeFailure:
            return nil
            
        case let .outside(outside):
            switch outside {
            case .main:
                return .main
            }
            
        case .templates:
            return .templates
        }
    }
}

// MARK: - TransfersPicker

private extension TransfersPicker {
    
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
            .compactMap(\.select)
            .handleEvents(receiveOutput: {
                
                print($0)
            })
            .map { .select($0) }
            .eraseToAnyPublisher()
    }
    
    func dismiss() {
        
        flow.event(.dismiss)
    }
}

private extension PaymentsTransfersPersonalTransfersDomain.FlowDomain.State {
    
    var select: PaymentsTransfersPersonalSelect? {
        
        switch navigation {
        case .success(.scanQR):         return .scanQR
        case .none, .failure, .success: return nil
        }
    }
}
