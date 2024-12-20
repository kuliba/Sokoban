//
//  ComposedSegmentedPaymentProviderPickerFlowView.swift
//  Vortex
//
//  Created by Igor Malyarov on 04.08.2024.
//

import SwiftUI

struct ComposedSegmentedPaymentProviderPickerFlowViewFactory {
    
    let makePaymentsView: MakePaymentsView
    let makeAnywayServicePickerFlowView: MakeAnywayServicePickerFlowView
}

struct ComposedSegmentedPaymentProviderPickerFlowView<AnywayFlowView>: View
where AnywayFlowView: View {
    
    let flowModel: FlowModel
    let iconView: (IconDomain.Icon?) -> IconDomain.IconView
    let viewFactory: ComposedSegmentedPaymentProviderPickerFlowViewFactory
    
    var body: some View {
        
        SegmentedPaymentProviderPickerFlowView(
            flowModel: flowModel,
            operatorLabel: label(provider:),
            destinationContent: destinationContent(_:)
        )
    }
}

extension ComposedSegmentedPaymentProviderPickerFlowView {
    
    typealias FlowModel = SegmentedPaymentProviderPickerFlowModel
}

private extension ComposedSegmentedPaymentProviderPickerFlowView {
    
    func label(
        provider: SegmentedOperatorProvider
    ) -> some View {
        
        LabelWithIcon(
            title: provider.title,
            subtitle: provider.subtitle,
            config: .iVortex,
            iconView: iconView(provider.icon)
        )
    }
    
    typealias FlowState = SegmentedPaymentProviderPickerFlowState
    
    @ViewBuilder
    func destinationContent(
        _ destination: FlowState.Status.Destination
    ) -> some View {
        
        switch destination {
        case let .payByInstructions(node):
            viewFactory.makePaymentsView(node.model)
            
        case let .payments(node):
            viewFactory.makePaymentsView(node.model)
            
        case let .servicePicker(node):
            viewFactory.makeAnywayServicePickerFlowView(node.model)
                .navigationBarWithAsyncIcon(
                    title: node.title,
                    subtitle: node.subtitle,
                    dismiss: { node.model.event(.dismiss) },
                    icon: iconView(node.icon)
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

private extension Node where Model == AnywayServicePickerFlowModel {
    
    var title: String {
        
        model.state.content.state.payload.provider.origin.title
    }
    
    var subtitle: String? {
        
        model.state.content.state.payload.provider.origin.inn
    }
    
    var icon: IconDomain.Icon? {
        
        model.state.content.state.payload.provider.origin.icon.map { .md5Hash(.init($0)) }
    }
}
