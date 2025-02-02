//
//  RootViewFactory+makeCategoryPickerContentView.swift
//  Vortex
//
//  Created by Igor Malyarov on 15.01.2025.
//

import PayHubUI
import RxViewModel
import SwiftUI

extension ViewComponents {
    
    func makeCategoryPickerContentView(
        _ content: CategoryPickerContentDomain<ServiceCategory>.Content,
        select: @escaping (ServiceCategory) -> Void,
        headerHeight: CGFloat?
    ) -> some View {
        
        RxWrapperView(
            model: content,
            makeContentView: { state, event in
                
                CategoryPickerSectionContentView(
                    state: state,
                    event: event,
                    select: select,
                    config: .iVortex(headerHeight: headerHeight),
                    itemLabel: itemLabel
                )
            }
        )
    }
    
    private func itemLabel(
        item: CategoryPickerContentDomain<ServiceCategory>.State.Item
    ) -> some View {
        
        CategoryPickerSectionStateItemLabel(
            item: item,
            config: .iVortex,
            categoryIcon: categoryIcon,
            placeholderView: { PlaceholderView(opacity: 0.5) }
        )
    }
    
    private func categoryIcon(
        category: ServiceCategory
    ) -> some View {
        
        makeIconView(.md5Hash(.init(category.md5Hash)))
    }
}
