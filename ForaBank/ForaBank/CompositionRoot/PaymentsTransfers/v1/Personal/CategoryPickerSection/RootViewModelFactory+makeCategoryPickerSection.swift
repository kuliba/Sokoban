//
//  RootViewModelFactory+makeCategoryPickerSection.swift
//  ForaBank
//
//  Created by Igor Malyarov on 01.10.2024.
//

import CombineSchedulers
import ForaTools
import Foundation
import GenericRemoteService
import PayHub
import SberQR

extension RootViewModelFactory {
    
    @inlinable
    func makeCategoryPickerSection(
        _ nanoServices: PaymentsTransfersPersonalNanoServices
    ) -> CategoryPickerSectionDomain.Binder {
        
        let placeholderCount = settings.categoryPickerPlaceholderCount
        
        let content = composeLoadablePickerModel(
            load: nanoServices.loadCategories,
            reload: nanoServices.reloadCategories,
            suffix: (0..<placeholderCount).map { _ in .placeholder(.init()) },
            placeholderCount: placeholderCount
        )
        
        return compose(
            getNavigation: getNavigation,
            content: content,
            witnesses: witnesses()
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
        let selectedCategoryComposer = SelectedCategoryNavigationMicroServicesComposer(
            model: model,
            nanoServices: .init(
                makeMobile: makeMobilePayment,
                makeQR: makeQRScannerModel,
                makeQRNavigation: getQRNavigation,
                makeStandard: makeStandard,
                makeTax: makeTaxPayment,
                makeTransport: makeTransportPayment
            ),
            scheduler: schedulers.main
        )
        let microServices = selectedCategoryComposer.compose()
        
        microServices.getNavigation(select, notify, completion)
    }
}
