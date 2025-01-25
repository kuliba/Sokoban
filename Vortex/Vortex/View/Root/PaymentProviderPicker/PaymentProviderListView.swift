//
//  PaymentProviderListView.swift
//  Vortex
//
//  Created by Igor Malyarov on 28.11.2024.
//

import FooterComponent
import RxViewModel
import SwiftUI
import UtilityServicePrepaymentUI

struct PaymentProviderListView: View {
    
    let providerList: PaymentProviderPickerDomain.ProviderList
    let binder: PaymentProviderPickerDomain.Binder
    let makeIconView: MakeIconView
    
    var body: some View {
        
        RxWrapperView(model: providerList, makeContentView: makeContentView)
    }
}

private extension PaymentProviderListView {
    
    @ViewBuilder
    func makeContentView(
        state: PaymentProviderPickerDomain.ProviderListState,
        event: @escaping (PaymentProviderPickerDomain.ProviderListEvent) -> Void
    ) -> some View {
        
        ForEach(state.operators) { provider in
            
            makeProviderView(provider: provider, event: event)
        }
        
        makeFooterView()
    }
    
    func makeProviderView(
        provider: PaymentProviderPickerDomain.Provider,
        event: @escaping (PaymentProviderPickerDomain.ProviderListEvent) -> Void
    ) -> some View {
        
        Button(
            action: { binder.flow.selectProvider(provider) },
            label: {
                
                OperatorLabel(
                    title: provider.title,
                    subtitle: provider.inn,
                    config: .iVortex(),
                    iconView: makeIconView(md5Hash: provider.icon)
                )
                .contentShape(Rectangle())
            }
        )
        .plainListRow(insets: .init(top: 0, leading: 16, bottom: 0, trailing: 16))
        .onAppear { event(.didScrollTo(provider.id)) }
    }
    
    func makeIconView(
        md5Hash: String?
    ) -> some View {
        
        makeIconView(md5Hash.map { .md5Hash(.init($0)) })
    }
    
    func makeFooterView() -> some View {
        
        FooterView(
            state: .footer(.iVortex),
            event: binder.flow.handleFooterEvent(_:),
            config: .iVortex
        )
    }
}

extension Latest: Identifiable {}
