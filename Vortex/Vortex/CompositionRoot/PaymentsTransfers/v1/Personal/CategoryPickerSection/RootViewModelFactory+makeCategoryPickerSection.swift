//
//  RootViewModelFactory+makeCategoryPickerSection.swift
//  Vortex
//
//  Created by Igor Malyarov on 01.10.2024.
//

import Combine
import PayHubUI

protocol ReloadableCategoryPicker: CategoryPicker {
    
    func reload()
}

extension CategoryPickerSectionDomain.Binder: ReloadableCategoryPicker {
    
    func reload() {
        
        content.event(.reload)
    }
}

extension RootViewModelFactory {
    
    @inlinable
    func makeCategoryPickerSection(
    ) -> CategoryPickerSectionDomain.Binder {
        
        let nanoServices = composePaymentsTransfersPersonalNanoServices()
        
        return makeCategoryPickerSection(nanoServices: nanoServices)
    }
    
    @inlinable
    func makeCategoryPickerSection(
        nanoServices: PaymentsTransfersPersonalNanoServices
    ) -> CategoryPickerSectionDomain.Binder {
        
        let content = makeCategoryPickerContent(nanoServices)
        
        return composeBinder(
            content: content,
            delayProvider: delayProvider,
            getNavigation: getNavigation,
            witnesses: .init(emitting: emitting, dismissing: dismissing)
        )
    }
    
    @inlinable
    func delayProvider(
        navigation: CategoryPickerSectionDomain.Navigation
    ) -> Delay {
        
        switch navigation {
        case .failure:     return .milliseconds(100)
        case .destination: return settings.delay
        case .outside:     return .milliseconds(100)
        }
    }
    
    @inlinable
    func getNavigation(
        select category: CategoryPickerSectionDomain.Select,
        notify: @escaping CategoryPickerSectionDomain.Notify,
        completion: @escaping (CategoryPickerSectionDomain.Navigation) -> Void
    ) {
        switch category.paymentFlow {
        case .mobile:
            completion(.destination(.mobile(makeMobilePayment(
                closeAction: { notify(.dismiss) }
            ))))
            
        case .qr:
            completion(.outside(.qr))
            
        case .standard:
            completion(.outside(.standard(category)))
            
        case .taxAndStateServices:
            completion(.destination(.taxAndStateServices(makeTaxPayment(
                closeAction: { notify(.dismiss) }
            ))))
            
        case .transport:
            guard let transport = makeTransportPayment()
            else { return completion(.failure(.transport)) }
            
            completion(.destination(.transport(transport)))
        }
    }
}

private extension SelectedCategoryFailure {
    
    static let transport: Self = .init(
        id: .init(),
        message: "Ошибка создания транспортных платежей"
    )
}
