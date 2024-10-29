//
//  QRFlowView.swift
//  QRNavigationPreview
//
//  Created by Igor Malyarov on 29.10.2024.
//

import SwiftUI
import UIPrimitives

struct QRFlowView<ContentView, DestinationView>: View
where ContentView: View,
      DestinationView: View {
    
    let state: QRDomain.FlowDomain.State
    let event: (QRDomain.FlowDomain.Event) -> Void
    let contentView: () -> ContentView
    let destinationView: (Destination) -> DestinationView
    
    var body: some View {
        
        contentView()
            .navigationDestination(
                destination: state.destination,
                dismiss: { event(.dismiss) },
                content: destinationView
            )
    }
    
    typealias Destination = QRDomain.FlowDomain.State.Destination
}

extension QRDomain.FlowDomain.State {
    
    var destination: Destination? {
        
        switch navigation {
        case .none:
            return nil
            
        case let .payments(payments):
            return .payments(payments)
        }
    }
    
    enum Destination {
        
        case payments(Payments)
    }
}

extension QRDomain.FlowDomain.State.Destination: Identifiable {
    
    var id: ID {
        
        switch self {
        case let .payments(payments):
            return .payments(.init(payments))
        }
    }
    
    enum ID: Hashable {
        
        case payments(ObjectIdentifier)
    }
}

#Preview {
    QRFlowView(
        state: .init(),
        event: { print($0) },
        contentView: {
            
            Text("Content View")
        },
        destinationView: {
            
            Text("Destination View \(String(describing: $0))")
        }
    )
}
