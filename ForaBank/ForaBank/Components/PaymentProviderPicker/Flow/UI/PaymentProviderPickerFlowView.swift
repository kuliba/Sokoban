//
//  PaymentProviderPickerFlowView.swift
//  ForaBank
//
//  Created by Igor Malyarov on 01.08.2024.
//

import FooterComponent
import SwiftUI

struct PaymentProviderPickerFlowView<OperatorLabel, DestinationContent>: View
where OperatorLabel: View,
      DestinationContent: View {
    
    @ObservedObject var flowModel: FlowModel
    
    let operatorLabel: (SegmentedOperatorProvider) -> OperatorLabel
    let destinationContent: (FlowState.Status.Destination) -> DestinationContent
    
    var body: some View {
        
        content()
            .navigationDestination(
                destination: flowModel.state.destination,
                dismissDestination: { flowModel.event(.dismiss) },
                content: destinationContent
            )
    }
}

extension PaymentProviderPickerFlowView {
    
    typealias FlowModel = PaymentProviderPickerFlowModel
    typealias FlowState = PaymentProviderPickerFlowState
    typealias Operator = SegmentedOperatorData
    typealias Provider = SegmentedProvider
}

extension PaymentProviderPickerFlowState {
    
    var destination: Status.Destination? {
        
        guard case let .destination(destination) = status else { return nil }
        return destination
    }
}

extension PaymentProviderPickerFlowState.Status.Destination: Identifiable {
    
    var id: ID {
        
        switch self {
            
        case .operator:          return .operator
        case .payByInstructions: return .payByInstructions
        case .provider:          return .provider
        }
    }
    
    enum ID: Hashable {
        
        case `operator`
        case payByInstructions
        case provider
    }
}

private extension PaymentProviderPickerFlowView {
    
    func content() -> some View {
        
        PaymentProviderPickerWrapperView(
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
