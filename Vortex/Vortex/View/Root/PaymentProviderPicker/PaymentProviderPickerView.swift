//
//  PaymentProviderPickerView.swift
//  Vortex
//
//  Created by Igor Malyarov on 28.11.2024.
//

import PayHubUI
import RxViewModel
import SwiftUI
import UtilityServicePrepaymentUI

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
                makeOperationPickerView: { content in
                    
                    makeOperationPickerView(
                        search: binder.content.search,
                        content: content
                    )
                },
                makeProviderList: makePaymentProviderListView,
                makeSearchView: makeSearchView
            )
        )
        .ignoresSafeArea()
    }
    
    @ViewBuilder
    func makeOperationPickerView(
        search: PaymentProviderPickerDomain.Search?,
        content: OperationPickerDomain.Content
    ) -> some View {
        
        switch search {
        case .none:
            makeOperationPickerView(content: content)
            
        case let .some(search):
            HidingOnActiveSearch(search: search) {
                
                makeOperationPickerView(content: content)
            }
        }
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
            makeIconView: makeIconView,
            makeSearchView: EmptyView.init
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

/// Hide content if observing search is active.
struct HidingOnActiveSearch<Content: View>: View {
    
    @ObservedObject var search: RegularFieldViewModel
    
    let content: () -> Content
    var anchor: UnitPoint = .leading
    
    var body: some View {
        
        content()
            .scaleEffect(search.isActive ? 0.01 : 1, anchor: anchor)
            .frame(height: search.isActive ? 0.01 : nil, alignment: .bottom)
            .opacity(search.isActive ? 0 : 1)
            .animation(.bouncy, value: search.isActive)
    }
}
