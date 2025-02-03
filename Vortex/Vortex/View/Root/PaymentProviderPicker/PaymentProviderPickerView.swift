//
//  PaymentProviderPickerView.swift
//  Vortex
//
//  Created by Igor Malyarov on 28.11.2024.
//

import Combine
import PayHubUI
import RxViewModel
import SwiftUI
import UtilityServicePrepaymentUI

struct PaymentProviderPickerView: View {
    
    let binder: PaymentProviderPickerDomain.Binder
    let dismiss: () -> Void
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
                    dismiss: dismiss,
                    rightItem: .barcodeScanner {
                        
                        binder.flow.event(.select(.outside(.qr)))
                    }
                )
            }
        )
    }
}

extension PaymentProviderPickerDomain.Content {
    
    var isSearchActivePublisher: AnyPublisher<Bool, Never> {
        
        switch search {
        case .none:
            return Empty().eraseToAnyPublisher()
            
        case let .some(search):
            return search.$state.map(\.isEditing).eraseToAnyPublisher()
        }
    }
}

private extension PaymentProviderPickerView {
    
    func contentView() -> some View {
        
        PaymentProviderPickerContentView(
            content: binder.content,
            isSearchActivePublisher: binder.content.isSearchActivePublisher,
            factory: .init(
                makeOperationPickerView: makeOperationPickerView,
                makeProviderList: makePaymentProviderListView,
                makeSearchView: makeSearchView
            )
        )
        .ignoresSafeArea()
    }
    
    func makeOperationPickerView(
        content: OperationPickerDomain.Content
    ) -> some View {
        
        OperationPickerContentWrapperView(
            content: content,
            select: select,
            config: .init(label: .prod, view: .prod(height: 80)),
            makeLastPaymentLabel: makeLastPaymentLabel
        )
        .padding(.top)
    }
    
    func makeLastPaymentLabel(
        latest: Latest
    ) -> some View {
        
        LastPaymentLabel(
            amount: latest.amount.map { "\($0) ₽" } ?? "",
            title: latest.name,
            config: .iVortex,
            iconView: makeIconView(latest.md5Hash.map { .md5Hash(.init($0)) })
        )
        .contentShape(Rectangle())
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
    
    func makeSearchView(
        search: PaymentProviderPickerDomain.Search
    ) -> some View {
        
        DefaultCancellableSearchBarView(
            viewModel: search,
            textFieldConfig: .black16,
            cancel: {
                
                UIApplication.shared.endEditing()
                search.setText(to: nil)
            }
        )
        .padding(.horizontal, 16)
        .background(.white)
        .zIndex(1)
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
