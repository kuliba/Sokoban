//
//  ComposedSegmentedPaymentProviderPickerFlowView.swift
//  Vortex
//
//  Created by Igor Malyarov on 04.08.2024.
//

import FooterComponent
import RxViewModel
import SwiftUI

struct ComposedSegmentedPaymentProviderPickerFlowView<AnywayFlowView>: View
where AnywayFlowView: View {
    
    @ObservedObject var flowModel: FlowModel
    let viewFactory: ViewFactory
    
    var body: some View {
        
        SegmentedPaymentProviderPickerView(
            segments: flowModel.state.content.segments,
            providerView: providerView,
            footer: footer,
            config: .iVortex
        )
        .navigationDestination(
            destination: flowModel.state.destination,
            content: destinationContent
        )
    }
}

extension ComposedSegmentedPaymentProviderPickerFlowView {
    
    typealias FlowModel = SegmentedPaymentProviderPickerFlowModel
    typealias ViewFactory = ComposedSegmentedPaymentProviderPickerFlowViewFactory
}

struct ComposedSegmentedPaymentProviderPickerFlowViewFactory {
    
    let makeAnywayServicePickerFlowView: MakeAnywayServicePickerFlowView
    let makeIconView: MakeIconView
    let makePaymentsView: MakePaymentsView
}

private extension ComposedSegmentedPaymentProviderPickerFlowView {
    
    func providerView(
        provider: SegmentedOperatorProvider
    ) -> some View {
        
        Button {
            select(provider: provider)
        } label: {
            label(provider: provider)
        }
    }
    
    func select(
        provider: SegmentedOperatorProvider
    ) {
        switch provider {
        case let .operator(`operator`):
            select(select: .operator(`operator`))
            
        case let .provider(provider):
            select(select: .provider(provider))
        }
    }
    
    func select(
        select: SegmentedPaymentProviderPickerFlowEvent.Select
    ) {
        flowModel.event(.select(select))
    }
    
    func label(
        provider: SegmentedOperatorProvider
    ) -> some View {
        
        LabelWithIcon(
            title: provider.title,
            subtitle: provider.subtitle,
            config: .iVortex(),
            iconView: viewFactory.makeIconView(provider.icon)
        )
    }
    
    func footer() -> some View {
        
        FooterView(
            state: .footer(.iVortex),
            event: {
                switch $0 {
                case .addCompany:
                    flowModel.event(.goTo(.addCompany))
                    
                case .payByInstruction:
                    flowModel.event(.payByInstructions)
                }
            },
            config: .iVortex
        )
    }
    
    typealias FlowState = SegmentedPaymentProviderPickerFlowState
    
    @ViewBuilder
    func destinationContent(
        _ destination: FlowState.Navigation.Destination
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
                    icon: viewFactory.makeIconView(node.icon)
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

extension SegmentedPaymentProviderPickerFlowState {
    
    var destination: Navigation.Destination? {
        
        guard case let .destination(destination) = navigation 
        else { return nil }
        
        return destination
    }
}

extension SegmentedPaymentProviderPickerFlowState.Navigation.Destination: Identifiable {
    
    var id: ID {
        
        switch self {
        case let .payByInstructions(node):
            return .payByInstructions(.init(node.model))
            
        case let .payments(node):
            return .payments(.init(node.model))
            
        case let .servicePicker(node):
            return .servicePicker(.init(node.model))
        }
    }
    
    enum ID: Hashable {
        
        case payByInstructions(ObjectIdentifier)
        case payments(ObjectIdentifier)
        case servicePicker(ObjectIdentifier)
    }
}
