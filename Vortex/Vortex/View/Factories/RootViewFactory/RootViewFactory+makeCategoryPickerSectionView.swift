//
//  RootViewFactory+makeCategoryPickerSectionView.swift
//  Vortex
//
//  Created by Igor Malyarov on 29.11.2024.
//

import LoadableResourceComponent
import PayHub
import PayHubUI
import RxViewModel
import SwiftUI

extension RootViewFactory {
    
    @ViewBuilder
    func makeCategoryPickerSectionView(
        categoryPicker: PayHubUI.CategoryPicker
    ) -> some View {
        
        if let binder = categoryPicker.sectionBinder {
            
            makeCategoryPickerSectionView(binder: binder)
            
        } else {
            
            Text("Unexpected categoryPicker type \(String(describing: categoryPicker))")
                .foregroundColor(.red)
        }
    }
    
    private func makeCategoryPickerSectionView(
        binder: CategoryPickerSectionDomain.Binder
    ) -> some View {
        
        RxWrapperView(
            model: binder.flow,
            makeContentView: {
                
                CategoryPickerSectionFlowView(
                    state: $0,
                    event: $1,
                    factory: .init(
                        makeAlert: makeAlert(binder: binder),
                        makeContentView: { makeContentView(binder.content) },
                        makeDestinationView: makeDestinationView
                    )
                )
            }
        )
        .padding(.top, 20)
    }
    
    private func makeContentView(
        _ content: CategoryPickerSectionDomain.Content
    ) -> some View {
        
        RxWrapperView(
            model: content,
            makeContentView: { state, event in
                
                CategoryPickerSectionContentView(
                    state: state,
                    event: event,
                    config: .iVortex,
                    itemLabel: itemLabel
                )
            }
        )
    }
    
    private func makeAlert(
        binder: CategoryPickerSectionDomain.Binder
    ) -> (SelectedCategoryFailure) -> Alert {
        
        return { failure in
            
            return .init(
                with: .error(message: failure.message, event: .dismiss),
                event: { binder.flow.event($0) }
            )
        }
    }
    
    private func itemLabel(
        item: CategoryPickerSectionDomain.ContentDomain.State.Item
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
    
    @ViewBuilder
    private func makeDestinationView(
        destination: SelectedCategoryNavigation.Destination
    ) -> some View {
        
        switch destination {
        case let .paymentFlow(paymentFlow):
            switch paymentFlow {
            case let .mobile(mobile):
                components.makePaymentsView(mobile.paymentsViewModel)
                                
            case let .taxAndStateServices(wrapper):
                components.makePaymentsView( wrapper.paymentsViewModel)
                
            case let .transport(transport):
                transportPaymentsView(transport)
            }
        }
    }
}
