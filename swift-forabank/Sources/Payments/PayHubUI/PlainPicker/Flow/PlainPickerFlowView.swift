//
//  PlainPickerFlowView.swift
//
//
//  Created by Igor Malyarov on 30.08.2024.
//

import PayHub
import SwiftUI

public struct PlainPickerFlowView<ContentView, DestinationView, Element, Destination>: View
where ContentView: View,
      DestinationView: View,
      Destination: Identifiable {
    
    private let state: State
    private let event: (Event) -> Void
    private let makeContentView: () -> ContentView
    private let makeDestinationView: (Destination) -> DestinationView
    
    public init(
        state: State, 
        event: @escaping (Event) -> Void,
        makeContentView: @escaping () -> ContentView,
        makeDestinationView: @escaping (Destination) -> DestinationView
    ) {
        self.state = state
        self.event = event
        self.makeContentView = makeContentView
        self.makeDestinationView = makeDestinationView
    }
    
    public var body: some View {
        
        makeContentView()
            .navigationDestination(
                destination: state.navigation,
                dismiss: { event(.dismiss) },
                content: makeDestinationView
            )
    }
}

public extension PlainPickerFlowView {
    
    typealias State = PlainPickerFlowState<Destination>
    typealias Event = PlainPickerFlowEvent<Element, Destination>
}
