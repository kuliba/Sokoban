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
    let destinationContent: (FlowState.Navigation.Destination) -> DestinationContent
    
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
    
    var destination: Navigation.Destination? {
        
        guard case let .destination(destination) = navigation else { return nil }
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
