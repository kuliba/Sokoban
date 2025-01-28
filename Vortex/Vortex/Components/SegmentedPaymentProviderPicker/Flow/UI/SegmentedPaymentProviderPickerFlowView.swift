//
//  SegmentedPaymentProviderPickerFlowView.swift
//  Vortex
//
//  Created by Igor Malyarov on 01.08.2024.
//

import FooterComponent
import RxViewModel
import SwiftUI
import UIPrimitives

struct SegmentedPaymentProviderPickerFlowView<OperatorLabel, DestinationContent>: View
where OperatorLabel: View,
      DestinationContent: View {
    
    @ObservedObject var flowModel: FlowModel
    
    let operatorLabel: (SegmentedOperatorProvider) -> OperatorLabel
    let destinationContent: (FlowState.Status.Destination) -> DestinationContent
    
    var body: some View {
        
        content()
            .navigationDestination(
                destination: flowModel.state.destination,
                content: destinationContent
            )
    }
}

extension SegmentedPaymentProviderPickerFlowView {
    
    typealias FlowModel = SegmentedPaymentProviderPickerFlowModel
    typealias FlowState = SegmentedPaymentProviderPickerFlowState
    typealias Operator = SegmentedOperatorData
    typealias Provider = SegmentedProvider
}

private extension SegmentedPaymentProviderPickerFlowView {
    
    func content() -> some View {
        
        RxWrapperView(
            model: flowModel.state.content,
            makeContentView: { state, event in
                
                SegmentedPaymentProviderPickerView(
                    segments: state.segments,
                    providerView: providerView,
                    footer: footer,
                    config: .iVortex
                )
            }
        )
    }
    
    func footer() -> some View {
        
        FooterView(
            state: .footer(.iVortex),
            event: {
                switch $0 {
                case .addCompany:
                    flowModel.state.content.event(.select(.addCompany))
                    
                case .payByInstruction:
                    flowModel.state.content.event(.select(.payByInstructions))
                }
            },
            config: .iVortex
        )
    }
    
    func providerView(
        segmented: SegmentedOperatorProvider
    ) -> some View {
        
        Button {
            select(segmented: segmented)
        } label: {
            operatorLabel(segmented)
        }
    }
    
    func select(
        segmented: SegmentedOperatorProvider
    ) {
        switch segmented {
        case let .operator(`operator`):
            flowModel.state.content.event(.select(.item(.operator(`operator`))))
            
        case let .provider(provider):
            flowModel.state.content.event(.select(.item(.provider(provider))))
        }
    }
}

extension SegmentedPaymentProviderPickerFlowState {
    
    var destination: Status.Destination? {
        
        guard case let .destination(destination) = status else { return nil }
        return destination
    }
}

extension SegmentedPaymentProviderPickerFlowState.Status.Destination: Identifiable {
    
    var id: ID {
        
        switch self {
            
        case .payByInstructions: return .payByInstructions
        case .payments:          return .payments
        case .servicePicker:     return .servicePicker
        }
    }
    
    enum ID: Hashable {
        
        case payByInstructions
        case payments
        case servicePicker
    }
}
