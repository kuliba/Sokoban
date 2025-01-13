//
//  RxStateWrapperView.swift
//  PayHubPreview
//
//  Created by Igor Malyarov on 24.08.2024.
//

import SwiftUI

public struct RxStateWrapperView<ContentView, State, Event, Effect>: View
where ContentView: View {
    
    @StateObject private var model: Model
    private let makeContentView: MakeContentView
    
    public init(
        model: Model,
        @ViewBuilder makeContentView: @escaping MakeContentView
    ) {
        self._model = .init(wrappedValue: model)
        self.makeContentView = makeContentView
    }
    
    public var body: some View {
        
        makeContentView(model.state, model.event(_:))
    }
}

public extension RxStateWrapperView {
    
    typealias Model = RxViewModel<State, Event, Effect>
    typealias MakeContentView = (State, @escaping (Event) -> Void) -> ContentView
}
