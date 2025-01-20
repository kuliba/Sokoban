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
        select: CategoryPickerSectionDomain.Select,
        notify:@escaping CategoryPickerSectionDomain.Notify,
        completion: @escaping (CategoryPickerSectionDomain.Navigation) -> Void
    ) -> Void {
        
        let composer = SelectedCategoryGetNavigationComposer(
            model: model,
            nanoServices: .init(
                makeMobile: makeMobilePayment,
                makeStandard: { _,_ in }, // standard is not called for Section
                makeTax: makeTaxPayment,
                makeTransport: makeTransportPayment
            ),
            scheduler: schedulers.main
        )
        
        composer.getNavigation(select, notify) {
            
            completion($0)
            _ = composer
        }
    }
}
