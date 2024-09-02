//
//  ComposedPlainPickerView.swift
//
//
//  Created by Igor Malyarov on 30.08.2024.
//

import PayHub
import SwiftUI

public struct ComposedPlainPickerView<ContentView, DestinationView, Element, Destination>: View
where ContentView: View,
      DestinationView: View,
      Destination: Identifiable {
    
    private let binder: Binder
    private let makeContentView: MakeContentView
    private let makeDestinationView: MakeDestinationView
    
    public init(
        binder: Binder,
        @ViewBuilder makeContentView: @escaping MakeContentView,
        @ViewBuilder makeDestinationView: @escaping MakeDestinationView
    ) {
        self.binder = binder
        self.makeContentView = makeContentView
        self.makeDestinationView = makeDestinationView
    }
    
    public var body: some View {
        
        PlainPickerFlowWrapperView(
            model: binder.flow,
            makeContentView: {
                
                PlainPickerFlowView(
                    state: $0,
                    event: $1,
                    makeContentView: {
                        
                        PlainPickerContentWrapperView(
                            model: binder.content,
                            makeContentView: makeContentView
                        )
                    },
                    makeDestinationView: makeDestinationView
                )
            }
        )
    }
}

public extension ComposedPlainPickerView {
    
    typealias Binder = PlainPickerBinder<Element, Destination>
    typealias State = PlainPickerContentState<Element>
    typealias Event = PlainPickerContentEvent<Element>
    typealias MakeContentView = (State, @escaping (Event) -> Void) -> ContentView
    typealias MakeDestinationView = (Destination) -> DestinationView
}
