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
    
    typealias MakeStandard = (ServiceCategory, @escaping (SelectedCategoryNavigation.Standard) -> Void) -> Void
    
    @inlinable
    func makeCategoryPickerSection(
        nanoServices: PaymentsTransfersPersonalNanoServices,
        makeStandard: @escaping MakeStandard
    ) -> ReloadableCategoryPicker {
        
        let content = makeContent(nanoServices)
        
        return composeBinder(
            content: content,
            delayProvider: delayProvider,
            getNavigation: getNavigation(makeStandard: makeStandard),
            witnesses: .init(emitting: emitting, dismissing: dismissing)
        )
    }
    
    @inlinable
    func delayProvider(
        navigation: CategoryPickerSectionDomain.Navigation
    ) -> Delay {
        
        switch navigation {
        case .failure:     return .milliseconds(100)
        case .paymentFlow: return settings.delay
        }
    }
    
    @inlinable
    func makeContent(
        _ nanoServices: PaymentsTransfersPersonalNanoServices
    ) -> CategoryPickerSectionDomain.Content {
        
        let placeholderCount = settings.categoryPickerPlaceholderCount
        
        return composeLoadablePickerModel(
            load: nanoServices.loadCategories,
            reload: nanoServices.reloadCategories,
            suffix: (0..<placeholderCount).map { _ in .placeholder(.init()) },
            placeholderCount: placeholderCount
        )
    }
    
    @inlinable
    func emitting(
        content: CategoryPickerSectionDomain.Content
    ) -> some Publisher<FlowEvent<CategoryPickerSectionDomain.Select, Never>, Never> {
        
        content.$state.compactMap(\.selected).map(FlowEvent.select)
    }
    
    @inlinable
    func dismissing(
        content: CategoryPickerSectionDomain.Content
    ) -> () -> Void {
        
        return { content.event(.select(nil)) }
    }
}

extension RootViewModelFactory {
    
    @inlinable
    func getNavigation(
        makeStandard: @escaping MakeStandard
    ) -> (
        CategoryPickerSectionDomain.Select,
        @escaping CategoryPickerSectionDomain.Notify,
        @escaping (CategoryPickerSectionDomain.Navigation) -> Void
    ) -> Void {
        
        let composer = SelectedCategoryGetNavigationComposer(
            model: model,
            nanoServices: .init(
                makeMobile: makeMobilePayment,
                makeStandard: makeStandard,
                makeTax: makeTaxPayment,
                makeTransport: makeTransportPayment
            ),
            scheduler: schedulers.main
        )
        
        return { select, notify, completion in
            
            composer.getNavigation(select, notify) {
                
                completion($0)
                _ = composer
            }
        }
    }
}
