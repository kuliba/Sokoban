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
    
    /// Renders `Category Picker Section` with header on `Payments Tab`
    @ViewBuilder
    func makeCategoryPickerSectionView(
        categoryPicker: CategoryPicker
    ) -> some View {
        
        if let binder = categoryPicker.sectionBinder {
            
            makeCategoryPickerSectionView(
                binder: binder,
                headerHeight: 24
            )
            
        } else {
            
            Text("Unexpected categoryPicker type \(String(describing: categoryPicker))")
                .foregroundColor(.red)
        }
    }
    
    /// Renders `Category Picker` without header,
    @ViewBuilder
    func makeCategoryPickerView(
        _ categoryPicker: CategoryPicker
    ) -> some View {
        
        if let binder = categoryPicker.sectionBinder {
            
            makeCategoryPickerSectionView(
                binder: binder,
                headerHeight: nil
            )
            
        } else {
            
            Text("Unexpected categoryPicker type \(String(describing: categoryPicker))")
                .foregroundColor(.red)
        }
    }
    
    private func makeCategoryPickerSectionView(
        binder: CategoryPickerSectionDomain.Binder,
        headerHeight: CGFloat?
    ) -> some View {
        
        RxWrapperView(
            model: binder.flow,
            makeContentView: {
                
                CategoryPickerSectionFlowView(
                    state: $0,
                    event: $1,
                    factory: .init(
                        makeAlert: makeAlert(binder: binder),
                        makeContentView: {
                            
                            makeContentView(
                                binder.content,
                                headerHeight: headerHeight
                            )
                        },
                        makeDestinationView: makeDestinationView
                    )
                )
            }
        )
        .padding(.top, 20)
    }
    
    private func makeContentView(
        _ content: CategoryPickerSectionDomain.Content,
        headerHeight: CGFloat?
    ) -> some View {
        
        RxWrapperView(
            model: content,
            makeContentView: { state, event in
                
                CategoryPickerSectionContentView(
                    state: state,
                    event: event,
                    config: .iVortex(headerHeight: headerHeight),
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
        destination: SelectedCategoryNavigation.PaymentFlow
    ) -> some View {
        
        switch destination {
        case let .mobile(mobile):
            components.makePaymentsView(mobile.paymentsViewModel)
            
        case .qr:
            EmptyView()
            
        case let .standard(standard):
            switch standard {
            case let .destination(destination):
                switch destination {
                case let .failure(binder):
                    components.serviceCategoryFailureView(binder: binder)
                    
                case let .success(binder):
                    makePaymentProviderPickerView(binder)
                }
                
            case .category:
                EmptyView()
            }
            
        case let .taxAndStateServices(wrapper):
            components.makePaymentsView( wrapper.paymentsViewModel)
            
        case let .transport(transport):
            transportPaymentsView(transport)
        }
    }
}
