//
//  SegmentedPaymentProviderPickerFlowView.swift
//  Vortex
//
//  Created by Igor Malyarov on 01.08.2024.
//

import SwiftUI
import UIPrimitives

struct SegmentedPaymentProviderPickerFlowView<Content, DestinationContent>: View
where Content: View,
      DestinationContent: View {
    
    @ObservedObject var flowModel: FlowModel
    
    let content: () -> Content
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
