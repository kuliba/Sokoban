//
//  PaymentProviderPickerView.swift
//  Vortex
//
//  Created by Igor Malyarov on 28.11.2024.
//

import PayHubUI
import RxViewModel
import SwiftUI

struct PaymentProviderPickerView: View {
    
    let binder: PaymentProviderPickerDomain.Binder
    let components: ViewComponents
    let makeIconView: MakeIconView
    
    var body: some View {
        
        RxWrapperView(
            model: binder.flow,
            makeContentView: { state, event in
                
                PaymentProviderPickerFlowView(
                    state: state.navigation,
                    event: event,
                    contentView: contentView,
                    destinationView: destinationView
                )
                .navigationBarHidden(true)
                .navigationBarWithBack(
                    title: binder.content.title,
                    dismiss: { binder.flow.event(.dismiss) },
                    rightItem: .barcodeScanner {
                        
                        binder.flow.event(.select(.outside(.qr)))
                    }
                )
            }
        )
    }
}

private extension PaymentProviderPickerView {
    
    func contentView() -> some View {
        
        PaymentProviderPickerContentView(
            content: binder.content,
            factory: .init(
                makeOperationPickerView: makeOperationPickerView,
                makeProviderList: makePaymentProviderListView,
                makeSearchView: { _ in EmptyView() }
            )
        )
        .ignoresSafeArea()
    }
    
    func makeOperationPickerView(
        _ content: OperationPickerDomain.Content
    ) -> some View {
        
        OperationPickerContentWrapperView(
            content: content,
            select: select,
            config: .init(label: .iVortex, latest: .prod(iconSize: 40), view: .prod)
        )
    }
    
    func select(_ element: OperationPickerElement<Latest>) {
        
        guard case let .latest(latest) = element else { return }
        
        binder.flow.event(.select(.latest(latest)))
    }
    
    func makePaymentProviderListView(
        providerList: PaymentProviderPickerDomain.ProviderList
    ) -> some View {
        
        PaymentProviderListView(
            providerList: providerList,
            binder: binder,
            makeIconView: makeIconView
        )
    }
    
    @ViewBuilder
    func destinationView(
        _ destination: PaymentProviderPickerDomain.Destination
    ) -> some View {
        
        PaymentProviderPickerDestinationView(
            dismiss: { binder.flow.event(.dismiss) },
            detailPayment: { binder.flow.event(.select(.detailPayment)) },
            destination: destination,
            components: components,
            makeIconView: makeIconView
        )
    }
}
