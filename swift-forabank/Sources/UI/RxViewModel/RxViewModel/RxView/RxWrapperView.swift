//
//  RxWrapperView.swift
//  PayHubPreview
//
//  Created by Igor Malyarov on 24.08.2024.
//

import SwiftUI

public struct RxWrapperView<ContentView, State, Event, Effect>: View
where ContentView: View {
    
    @ObservedObject private var model: Model
    private let makeContentView: MakeContentView
    
    public init(
        model: Model,
        @ViewBuilder makeContentView: @escaping MakeContentView
    ) {
        self.model = model
        self.makeContentView = makeContentView
    }
    
    public var body: some View {
        
        makeContentView(model.state, model.event(_:))
    }
}

public extension RxWrapperView {
    
    typealias Model = RxViewModel<State, Event, Effect>
    typealias MakeContentView = (State, @escaping (Event) -> Void) -> ContentView
}
