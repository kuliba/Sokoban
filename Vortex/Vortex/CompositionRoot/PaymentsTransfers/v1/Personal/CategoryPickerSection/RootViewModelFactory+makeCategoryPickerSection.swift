//
//  RootViewModelFactory+makeCategoryPickerSection.swift
//  Vortex
//
//  Created by Igor Malyarov on 01.10.2024.
//

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
        _ nanoServices: PaymentsTransfersPersonalNanoServices
    ) -> ReloadableCategoryPicker {
        
        return compose(
            getNavigation: getNavigation,
            content: makeContent(nanoServices),
            witnesses: witnesses()
        )
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
    
    private func witnesses() -> CategoryPickerSectionDomain.Composer.Witnesses {
        
        return .init(
            emitting: { $0.$state.compactMap(\.selected) },
            dismissing: { content in { content.event(.select(nil)) }}
        )
    }
}

extension RootViewModelFactory {
    
    @inlinable
    func getNavigation(
        select: CategoryPickerSectionDomain.Select,
        notify: @escaping CategoryPickerSectionDomain.Notify,
        completion: @escaping (CategoryPickerSectionDomain.Navigation) -> Void
    ) {
        let composer = SelectedCategoryGetNavigationComposer(
            model: model,
            nanoServices: .init(
                makeMobile: makeMobilePayment,
                makeTax: makeTaxPayment,
                makeTransport: makeTransportPayment
            ),
            scheduler: schedulers.main
        )
        
        composer.getNavigation(select, notify, completion)
    }
}
