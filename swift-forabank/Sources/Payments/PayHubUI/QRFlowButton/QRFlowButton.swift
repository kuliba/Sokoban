//
//  QRFlowButton.swift
//
//
//  Created by Igor Malyarov on 18.08.2024.
//

import PayHub
import SwiftUI

public struct QRFlowButton<Destination, DestinationContent, QRFlowButtonLabel: View>: View
where Destination: Identifiable,
      DestinationContent: View {
    
    @StateObject private var model: Model
    
    private let buttonLabel: () -> QRFlowButtonLabel
    private let destinationContent: (Destination) -> DestinationContent
    
    public init(
        model: Model, 
        buttonLabel: @escaping () -> QRFlowButtonLabel,
        destinationContent: @escaping (Destination) -> DestinationContent
    ) {
        self._model = .init(wrappedValue: model)
        self.buttonLabel = buttonLabel
        self.destinationContent = destinationContent
    }
    
    public var body: some View {
        
        Button(action: { model.event(.buttonTap) }, label: buttonLabel)
            .fullScreenCover(
                cover: model.state.destination,
                dismiss: { model.event(.dismissDestination) },
                content: destinationContent
            )
    }
}

public extension QRFlowButton {
    
    typealias Model = QRFlowButtonModel<Destination>
}

// MARK: - Previews

struct QRFlowButton_Previews: PreviewProvider {
    
    static var previews: some View {
        
        NavigationView {
            
            qrFlowButton()
                .toolbar(content: qrFlowButton)
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    @ViewBuilder
    private static func qrFlowButton(
    ) -> some View {
        
        let reducer = QRFlowButtonReducer<QRFlowButtonDestination>()
        let effectHandler = QRFlowButtonEffectHandler<QRFlowButtonDestination>(
            microServices: .init(makeDestination: { $0(.open) })
        )
        
        let model = QRFlowButtonModel(
            initialState: .init(),
            reduce: reducer.reduce(_:_:),
            handleEffect: effectHandler.handleEffect(_:_:)
        )
        
        QRFlowButton(
            model: model,
            buttonLabel: {
                
                Label("Open QR Scanner", systemImage: "qrcode")
            },
            destinationContent: { (destination: QRFlowButtonDestination) in
                
                switch destination {
                case .open:
                    VStack(spacing: 32) {
                        
                        Text("QR Scanner")
                        
                        Button("Close") { model.event(.dismissDestination) }
                    }
                }
            }
        )
    }
    
    private enum QRFlowButtonDestination: Identifiable {
        
        case open
        
        var id: Self { self }
    }
}
