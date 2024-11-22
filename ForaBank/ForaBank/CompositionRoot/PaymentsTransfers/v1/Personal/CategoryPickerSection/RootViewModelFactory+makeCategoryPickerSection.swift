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
        nanoServices: PaymentsTransfersPersonalNanoServices
    ) -> CategoryPickerSectionDomain.Binder {
        
        let pageSize = settings.pageSize
        let placeholderCount = settings.categoryPickerPlaceholderCount
        
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
        
        let categoryPickerContent = composeLoadablePickerModel(
            load: nanoServices.loadCategories,
            reload: nanoServices.reloadCategories,
            suffix: (0..<placeholderCount).map { _ in .placeholder(.init()) },
            placeholderCount: placeholderCount
        )
        
        return compose(
            getNavigation: microServices.getNavigation,
            content: categoryPickerContent,
            witnesses: witnesses()
        )
    }
    
    private func witnesses() -> CategoryPickerSectionDomain.Composer.Witnesses {
        
        return .init(
            emitting: { $0.$state.compactMap(\.selected) },
            receiving: { content in { content.event(.select(nil)) }}
        )
    }
}
