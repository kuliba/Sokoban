//
//  NavigationDestinationFlowButton.swift
//
//
//  Created by Igor Malyarov on 18.08.2024.
//

import SwiftUI

/// A custom button that triggers a navigation to a destination view when tapped.
///
/// `NavigationDestinationFlowButton` is a reusable SwiftUI component that navigates to a specified view
/// when the button is tapped. The button label and the destination content are provided by the caller.
/// The component uses a model to manage its state and respond to button tap and dismiss events.
public struct NavigationDestinationFlowButton<Destination, DestinationContent, ButtonLabel: View>: View
where Destination: Identifiable,
      DestinationContent: View {
    
    /// The model that manages the state of the `NavigationDestinationFlowButton`.
    /// It is responsible for handling events and controlling the destination view.
    @StateObject private var model: Model
    
    /// A closure that returns the view to be used as the button label.
    private let buttonLabel: () -> ButtonLabel
    
    /// A closure that returns the content to be displayed when navigating to the destination.
    /// The content is determined by the current state of the `Destination`.
    private let destinationContent: (Destination) -> DestinationContent
    
    /// Initialises a new `NavigationDestinationFlowButton` with the given model, button label, and destination content.
    ///
    /// - Parameters:
    ///   - model: An instance of `FlowButtonModel` that manages the state and events for this button.
    ///   - buttonLabel: A closure that provides the label view for the button.
    ///   - destinationContent: A closure that provides the content view for the navigation destination,
    ///     based on the current `Destination`.
    public init(
        model: Model,
        buttonLabel: @escaping () -> ButtonLabel,
        destinationContent: @escaping (Destination) -> DestinationContent
    ) {
        self._model = .init(wrappedValue: model)
        self.buttonLabel = buttonLabel
        self.destinationContent = destinationContent
    }
    
    public var body: some View {
        
        Button {
            model.event(.buttonTap)
        } label: {
            buttonLabel().contentShape(Rectangle())
        }
        .navigationDestination(
            destination: model.state.destination,
            dismiss: { model.event(.dismissDestination) },
            content: destinationContent
        )
    }
}

public extension NavigationDestinationFlowButton {
    
    typealias Model = FlowButtonModel<Destination>
}

// MARK: - Previews

import PayHub

struct NavigationDestinationFlowButton_Previews: PreviewProvider {
    
    static var previews: some View {
        
        NavigationView {
            
            flowButton()
                .toolbar(content: flowButton)
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    @ViewBuilder
    private static func flowButton(
    ) -> some View {
        
        let reducer = FlowButtonReducer<Destination>()
        let effectHandler = FlowButtonEffectHandler<Destination>(
            microServices: .init(makeDestination: { $0(.open) })
        )
        
        let model = FlowButtonModel(
            initialState: .init(),
            reduce: reducer.reduce(_:_:),
            handleEffect: effectHandler.handleEffect(_:_:)
        )
        
        NavigationDestinationFlowButton(
            model: model,
            buttonLabel: {
                
                Label("Open Profile", systemImage: "person")
            },
            destinationContent: { (destination: Destination) in
                
                switch destination {
                case .open:
                    VStack(spacing: 32) {
                        
                        Text("Profile")
                        
                        Button("Close") { model.event(.dismissDestination) }
                    }
                }
            }
        )
    }
    
    private enum Destination: Identifiable {
        
        case open
        
        var id: Self { self }
    }
}
