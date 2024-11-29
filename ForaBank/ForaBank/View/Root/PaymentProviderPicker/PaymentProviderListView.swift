//
//  PaymentProviderListView.swift
//  ForaBank
//
//  Created by Igor Malyarov on 28.11.2024.
//

import FooterComponent
import RxViewModel
import SwiftUI
import UtilityServicePrepaymentUI

struct PaymentProviderListView: View {
    
    let providerList: PaymentProviderPicker.ProviderList
    let binder: PaymentProviderPicker.Binder
    let makeIconView: MakeIconView
    
    var body: some View {
        
        RxWrapperView(
            model: providerList,
            makeContentView: makeContentView
        )
    }
}

private extension PaymentProviderListView {
    
    func makeContentView(
        state: PaymentProviderPicker.ProviderListState,
        event: @escaping (PaymentProviderPicker.ProviderListEvent) -> Void
    ) -> some View {
        
        PrepaymentPickerSuccessView(
            state: state,
            event: event,
            factory: .init(
                makeFooterView: makeFooterView,
                makeLastPaymentView: makeLastPaymentView,
                makeOperatorView: makeOperatorView,
                makeSearchView: makeSearchView
            )
        )
    }
    
    func makeFooterView(
        _ state: Bool
    ) -> some View {
        
        FooterView(
            state: state ? .failure(.iFora) : .footer(.iFora),
            event: binder.flow.handleFooterEvent(_:),
            config: .iFora
        )
    }
    
    func makeLastPaymentView(
        latest: Latest
    ) -> some View {
        
        makeLatestPaymentView(latest: latest, event: binder.flow.selectLatest(_:))
    }
    
    func makeLatestPaymentView(
        latest: Latest,
        event: @escaping (Latest) -> Void
    ) -> some View {
        
        Button(
            action: { event(latest) },
            label: {
                
                LastPaymentLabel(
                    amount: latest.amount.map { "\($0) ₽" } ?? "",
                    title: latest.name,
                    config: .iFora,
                    iconView: makeIconView(md5Hash: latest.md5Hash)
                )
                .contentShape(Rectangle())
            }
        )
    }
    
    func makeOperatorView(
        `operator`: PaymentServiceOperator
    ) -> some View {
        
        makeOperatorView(provider: `operator`, event: binder.flow.selectProvider(_:))
    }
    
    func makeOperatorView(
        provider: PaymentProviderPicker.Provider,
        event: @escaping (PaymentProviderPicker.Provider) -> Void
    ) -> some View {
        
        Button(
            action: { event(provider) },
            label: {
                
                OperatorLabel(
                    title: provider.name,
                    subtitle: provider.inn,
                    config: .iFora,
                    iconView: makeIconView(md5Hash: provider.md5Hash)
                )
                .contentShape(Rectangle())
            }
        )
    }
    
    @ViewBuilder
    func makeSearchView() -> some View {
        
        binder.content.search.map { search in
            
            DefaultCancellableSearchBarView(
                viewModel: search,
                textFieldConfig: .black16,
                cancel: {
                    
                    UIApplication.shared.endEditing()
                    search.setText(to: nil)
                }
            )
        }
    }
    
    func makeIconView(
        md5Hash: String?
    ) -> some View {
        
        makeIconView(md5Hash.map { .md5Hash(.init($0)) })
    }
}
