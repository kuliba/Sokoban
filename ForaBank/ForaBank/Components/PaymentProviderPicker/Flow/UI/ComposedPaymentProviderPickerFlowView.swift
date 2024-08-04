//
//  ComposedPaymentProviderPickerFlowView.swift
//  ForaBank
//
//  Created by Igor Malyarov on 04.08.2024.
//

import SwiftUI

struct ComposedPaymentProviderPickerFlowView: View {
    
    let flowModel: FlowModel
    let iconView: (IconDomain.Icon?) -> IconDomain.IconView
    let makeAnywayFlowView: (AnywayFlowModel) -> AnywayFlowView<PaymentCompleteView>
    
    var body: some View {
        
        PaymentProviderPickerFlowView(
            flowModel: flowModel,
            operatorLabel: label(provider:),
            destinationContent: destinationContent(_:)
        )
    }
}

extension ComposedPaymentProviderPickerFlowView {
    
    typealias FlowModel = PaymentProviderPickerFlowModel
}

private extension ComposedPaymentProviderPickerFlowView {
    
    func label(
        provider: SegmentedOperatorProvider
    ) -> some View {
        
        LabelWithIcon(
            title: provider.title,
            subtitle: provider.subtitle,
            config: .iFora,
            iconView: iconView(provider.icon)
        )
    }
    
    typealias FlowState = PaymentProviderPickerFlowState
    
    @ViewBuilder
    func destinationContent(
        _ destination: FlowState.Status.Destination
    ) -> some View {
        
        switch destination {
        case let .payByInstructions(node):
            PaymentsView(viewModel: node.model)
            
        case let .payments(node):
            PaymentsView(viewModel: node.model)
            
        case let .servicePicker(node):
            AnywayServicePickerFlowView(
                flowModel: node.model,
                factory: .init(
                    makeAnywayFlowView: makeAnywayFlowView,
                    makeIconView: iconView
                )
            )
        }
    }
}

extension SegmentedOperatorProvider {
    
    var subtitle: String? {
        
        switch self {
        case let .operator(`operator`):
            return `operator`.origin.synonymList.first
            
        case let .provider(provider):
            return provider.origin.inn
        }
    }
    
    var icon: IconDomain.Icon? {
        
        switch self {
        case let .operator(`operator`):
            return `operator`.origin.svg.map { .svg($0) }
            
        case let .provider(provider):
            return provider.origin.icon.map { .md5Hash(.init($0)) }
        }
    }
}

private extension OperatorGroupData.OperatorData {
    
    var svg: String? {
        
        logotypeList.first?.svgImage?.description
    }
}
