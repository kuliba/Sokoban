//
//  RootViewFactory+makeOperationPickerView.swift
//  Vortex
//
//  Created by Igor Malyarov on 29.11.2024.
//

import PayHubUI
import RemoteServices
import RxViewModel
import SwiftUI
import UtilityServicePrepaymentUI

extension RootViewFactory {
    
    @ViewBuilder
    func makeOperationPickerView(
        operationPicker: OperationPicker
    ) -> some View {
        
        OperationPickerView(
            operationPicker: operationPicker, 
            components: components,
            makeIconView: makeIconView
        )
    }
}

struct OperationPickerView: View {

    let operationPicker: OperationPicker
    let components: ViewComponents
    let makeIconView: MakeIconView

    var body: some View {
        
        if let binder = operationPicker.operationBinder {
            
            makeOperationPickerView(binder: binder)
            
        } else {
            
            Text("Unexpected operationPicker type \(String(describing: operationPicker))")
                .foregroundColor(.red)
        }
    }
}

extension OperationPickerView {
    
    private func makeOperationPickerView(
        binder: OperationPickerDomain.Binder
    ) -> some View {
        
        RxWrapperView(
            model: binder.flow,
            makeContentView: {
                
                OperationPickerFlowView(
                    state: $0,
                    event: $1,
                    factory: .init(
                        makeContent: { makeContentView(binder.content) },
                        makeDestination: {
                            
                            makeDestinationView(
                                destination: $0,
                                closeAction: { binder.flow.event(.dismiss) }
                            )
                        }
                    )
                )
            }
        )
    }
    
    private func makeContentView(
        _ content: OperationPickerDomain.Content
    ) -> some View {
        
        RxWrapperView(
            model: content,
            makeContentView: { state, event in
                
                OperationPickerContentView(
                    state: state,
                    event: event,
                    config: .prod,
                    itemLabel: operationPickerItemLabel
                )
            }
        )
        .onFirstAppear { content.event(.load) }
    }
    
    private func operationPickerItemLabel(
        item: OperationPickerState.Item
    ) -> some View {
        
        OperationPickerStateItemLabel(
            item: item,
            config: .iVortex,
            latestView: { latest in
                
                // TODO: replace `LastPaymentLabel` with `LatestPaymentButtonLabelView(latest: latest, config: .prod())` - see below
                LastPaymentLabel(
                    amount: latest.amount.map { "\($0) ₽" } ?? "",
                    title: latest.name,
                    config: .primary,
                    iconView: makeIconView(latest.md5Hash.map { .md5Hash(.init($0)) })
                )
            },
            placeholderView:  {
                
                LatestPlaceholder(
                    opacity: 1,
                    config: OperationPickerStateItemLabelConfig.iVortex.latestPlaceholder
                )
            }
        )
    }
    
    @ViewBuilder
    private func makeDestinationView(
        destination: OperationPickerDomain.Navigation.Destination,
        closeAction: @escaping () -> Void
    ) -> some View {
        
        switch destination {
        case .exchangeFailure:
            EmptyView()
            
        case let .exchange(currencyWalletViewModel):
            components.makeCurrencyWalletView(currencyWalletViewModel)
            
        case let .latest(latest):
            switch latest {
            case let .anywayPayment(node):
                let payload = node.model.state.content.state.transaction.context.outline.payload
                
                components.makeAnywayFlowView(node.model)
                    .navigationBarWithAsyncIcon(
                        title: payload.title,
                        subtitle: payload.subtitle,
                        dismiss: closeAction,
                        icon: makeIconView(payload.icon.map { .md5Hash(.init($0)) }),
                        style: .normal
                    )
                
            case let .meToMe(meToMe):
                components.makePaymentsMeToMeView(meToMe)
                
            case let .payments(payments):
                components.makePaymentsView(payments)
            }
        }
    }
}

extension LatestPaymentButtonLabelView {
    
    init(
        latest: Latest,
        config: LatestPaymentButtonLabelConfig
    ) {
        self.init(label: latest.label, config: config)
    }
}

private extension Latest {
    
    var label: LatestPaymentButtonLabel {
        
        switch origin {
        case let .service(service):
            return service.label
            
        case let .withPhone(withPhone):
            return withPhone.label
        }
    }
}

// LatestPaymentsViewComponent.swift:204

private extension RemoteServices.ResponseMapper.LatestPayment.Service {
    
    var label: LatestPaymentButtonLabel {
        
        return .init(
            amount: amount.map(String.init), 
            avatar: .text(name ?? lpName ?? ""),
            description: "",
            topIcon: nil
        )
    }
}

private extension RemoteServices.ResponseMapper.LatestPayment.WithPhone {
    
    var label: LatestPaymentButtonLabel {
        
        return .init(
            amount: amount.map(String.init),
            avatar: .text(name ?? ""),
            description: "",
            topIcon: nil
        )
    }
}
