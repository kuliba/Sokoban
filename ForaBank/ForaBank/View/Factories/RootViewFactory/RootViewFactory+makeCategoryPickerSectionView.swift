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
    
    func makeCategoryPickerSectionView(
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
    
    func makeCategoryPickerSectionAlert(
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
    func makeCategoryPickerSectionDestinationView(
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
    
    @ViewBuilder
    func makeCategoryPickerSectionFullScreenCoverView(
        cover: CategoryPickerSectionNavigation.FullScreenCover
    ) -> some View {
        
        NavigationView {
            
            components.makeQRView(cover.qr.qrScanner)
        }
        .navigationViewStyle(.stack)
    }
    
    @ViewBuilder
    func transportPaymentsView(
        _ transport: TransportPaymentsViewModel
    ) -> some View {
        
        components.makeTransportPaymentsView(transport)
            .navigationBarTitle("", displayMode: .inline)
            .navigationBarBackButtonHidden(true)
            .navigationBar(
                with: .with(
                    title: "Транспорт",
                    navLeadingAction: {},//viewModel.dismiss,
                    navTrailingAction: {}//viewModel.openScanner
                )
            )
    }
    
    @ViewBuilder
    func qrDestinationView(
        _ qrDestination: QRNavigation.Destination
    ) -> some View {
        
        switch qrDestination {
        case let .qrFailedViewModel(qrFailedViewModel):
            components.makeQRFailedView(qrFailedViewModel)
            
        case let .internetTV(viewModel):
            InternetTVDetailsView(viewModel: viewModel)
                .navigationBarTitle("", displayMode: .inline)
                .edgesIgnoringSafeArea(.all)
            
        case let .operatorSearch(viewModel):
            components.makeQRSearchOperatorView(viewModel)
                .navigationBarTitle("", displayMode: .inline)
                .navigationBarBackButtonHidden(true)
            
        case let .payments(wrapper):
            components.makePaymentsView(wrapper.paymentsViewModel)
            
        case let .paymentComplete(paymentComplete):
            components.makePaymentsSuccessView(paymentComplete)
            
        case let .providerPicker(providerPicker):
            paymentProviderPicker(providerPicker)
            
        case let .sberQR(sberQR):
            makeSberQRConfirmPaymentView(sberQR)
            
        case let .servicePicker(servicePicker):
            servicePickerView(servicePicker)
        }
    }
    
    func paymentProviderPicker(
        _ flowModel: SegmentedPaymentProviderPickerFlowModel
    ) -> some View {
        
        components.makeSegmentedPaymentProviderPickerView(flowModel)
        //    .navigationBarWithBack(
        //        title: PaymentsTransfersSectionType.payments.name,
        //        dismiss: viewModel.dismissPaymentProviderPicker,
        //        rightItem: .barcodeScanner(
        //            action: viewModel.dismissPaymentProviderPicker
        //        )
        //    )
    }
    
    @ViewBuilder
    func servicePickerView(
        _ flowModel: AnywayServicePickerFlowModel
    ) -> some View {
        
        let provider = flowModel.state.content.state.payload.provider
        
        components.makeAnywayServicePickerFlowView(flowModel)
//        .navigationBarWithAsyncIcon(
//            title: provider.origin.title,
//            subtitle: provider.origin.inn,
//            dismiss: viewModel.dismissProviderServicePicker,
//            icon: viewFactory.iconView(provider.origin.icon),
//            style: .normal
//        )
    }
}
