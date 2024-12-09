//
//  RootViewFactory+qrDestinationView.swift
//  Vortex
//
//  Created by Igor Malyarov on 29.11.2024.
//

import SwiftUI

extension RootViewFactory {
    
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
    
    private func paymentProviderPicker(
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
    private func servicePickerView(
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
