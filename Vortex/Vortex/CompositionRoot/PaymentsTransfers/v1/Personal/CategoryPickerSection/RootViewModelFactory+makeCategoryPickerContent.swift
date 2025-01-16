//
//  RootViewModelFactory+makeCategoryPickerContent.swift
//  Vortex
//
//  Created by Igor Malyarov on 15.01.2025.
//

import Combine
import PayHubUI

extension RootViewModelFactory {
    
    @inlinable
    func makeCategoryPickerContent(
        _ nanoServices: PaymentsTransfersPersonalNanoServices
    ) -> CategoryPickerContentDomain<ServiceCategory>.Content {
        
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
        content: CategoryPickerContentDomain<ServiceCategory>.Content
    ) -> some Publisher<FlowEvent<CategoryPickerSectionDomain.Select, Never>, Never> {
        
        content.$state.compactMap(\.selected).map(FlowEvent.select)
    }
    
    @inlinable
    func dismissing(
        content: CategoryPickerContentDomain<ServiceCategory>.Content
    ) -> () -> Void {
        
        return { content.event(.select(nil)) }
    }
}
