//
//  RootViewFactory+makeCategoryPickerSectionView.swift
//  ForaBank
//
//  Created by Igor Malyarov on 29.11.2024.
//

import LoadableResourceComponent
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
        
        ComposedCategoryPickerSectionView(
            binder: binder,
            factory: .init(
                makeAlert: makeCategoryPickerSectionAlert(binder: binder),
                makeContentView: {
                    
                    RxWrapperView(
                        model: binder.content,
                        makeContentView: { state, event in
                            
                            CategoryPickerSectionContentView(
                                state: state,
                                event: event,
                                config: .iFora,
                                itemLabel: itemLabel
                            )
                        }
                    )
                },
                makeDestinationView: makeCategoryPickerSectionDestinationView,
                makeFullScreenCoverView: makeCategoryPickerSectionFullScreenCoverView
            )
        )
        .padding(.top, 20)
    }
    
    private func makeCategoryPickerSectionAlert(
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
            config: .iFora,
            categoryIcon: categoryIcon,
            placeholderView: { PlaceholderView(opacity: 0.5) }
        )
    }
    
    private func categoryIcon(
        category: ServiceCategory
    ) -> some View {
        
        Color.blue.opacity(0.1)
    }
    
    @ViewBuilder
    private func makeCategoryPickerSectionDestinationView(
        destination: CategoryPickerSectionNavigation.Destination
    ) -> some View {
        
        switch destination {
        case let .paymentFlow(paymentFlow):
            switch paymentFlow {
            case let .mobile(mobile):
                components.makePaymentsView(mobile.paymentsViewModel)
                
            case let .standard(standard):
                switch standard {
                case let .failure(failedPaymentProviderPicker):
                    Text("TBD: \(String(describing: failedPaymentProviderPicker))")
                    
                case let .success(binder):
                    makePaymentProviderPickerView(binder)
                }
                
            case let .taxAndStateServices(wrapper):
                components.makePaymentsView( wrapper.paymentsViewModel)
                
            case let .transport(transport):
                transportPaymentsView(transport)
            }
            
        case let .qrDestination(qrDestination):
            qrDestinationView(qrDestination)
        }
    }
    
    private func makeCategoryPickerSectionFullScreenCoverView(
        cover: CategoryPickerSectionNavigation.FullScreenCover
    ) -> some View {
        
        NavigationView {
            
            components.makeQRView(cover.qr.qrScanner)
        }
        .navigationViewStyle(.stack)
    }
}
