//
//  SegmentedPaymentProviderPickerFlowView.swift
//  ForaBank
//
//  Created by Igor Malyarov on 01.08.2024.
//

import FooterComponent
import SwiftUI

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
                dismissDestination: { flowModel.state.content.event(.deselect) },
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

private extension SegmentedPaymentProviderPickerFlowView {
    
    func content() -> some View {
        
        SegmentedPaymentProviderPickerWrapperView(
            model: flowModel.state.content,
            operatorLabel: operatorLabel,
            footer: {
                
                FooterView(
                    state: .footer(.iFora),
                    event: {
                        switch $0 {
                        case .addCompany:
                            flowModel.state.content.event(.select(.addCompany))
                            
                        case .payByInstruction:
                            flowModel.state.content.event(.select(.payByInstructions))
                        }
                    },
                    config: .iFora
                )
            },
            config: .iFora
        )
    }
}
