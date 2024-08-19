//
//  QRFlowButton.swift
//
//
//  Created by Igor Malyarov on 18.08.2024.
//

import PayHub
import SwiftUI

/// A custom button that triggers a full-screen cover when tapped.
///
/// `QRFlowButton` is a reusable SwiftUI component that presents a full-screen view (destination)
/// when the button is tapped. The button label and the full-screen content are provided by the caller.
/// The component uses a model to manage its state and respond to button tap and dismiss events.
///
/// - Parameters:
///   - Destination: The type of the destination view presented in the full-screen cover.
///     It must conform to `Identifiable`.
///   - DestinationContent: The type of the content view displayed in the full-screen cover.
///   - QRFlowButtonLabel: The type of the view used as the button label.
public struct QRFlowButton<Destination, DestinationContent, QRFlowButtonLabel: View>: View
where Destination: Identifiable,
      DestinationContent: View {
    
    /// The model that manages the state of the `QRFlowButton`.
    /// It is responsible for handling events and controlling the destination view.
    @StateObject private var model: Model
    
    /// A closure that returns the view to be used as the button label.
    private let buttonLabel: () -> QRFlowButtonLabel
    
    /// A closure that returns the content to be displayed in the full-screen cover.
    /// The content is determined by the current state of the `Destination`.
    private let destinationContent: (Destination) -> DestinationContent
    
    /// Initialises a new `QRFlowButton` with the given model, button label, and destination content.
    ///
    /// - Parameters:
    ///   - model: An instance of `QRFlowButtonModel` that manages the state and events for this button.
    ///   - buttonLabel: A closure that provides the label view for the button.
    ///   - destinationContent: A closure that provides the content view for the full-screen cover,
    ///     based on the current `Destination`.
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
