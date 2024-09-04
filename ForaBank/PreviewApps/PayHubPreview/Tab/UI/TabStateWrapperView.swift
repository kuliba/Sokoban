//
//  TabStateWrapperView.swift
//  PayHubPreview
//
//  Created by Igor Malyarov on 16.08.2024.
//

import SwiftUI

struct TabStateWrapperView<Content, ContentView>: View
where ContentView: View {
    
    @StateObject private var model: Model
    
    private let makeContent: MakeContentView
    
    init(
        model: Model,
        @ViewBuilder makeContent: @escaping MakeContentView
    ) {
        self._model = .init(wrappedValue: model)
        self.makeContent = makeContent
    }
    
    var body: some View {
        
        makeContent(model.state, model.event(_:))
    }
}

extension TabStateWrapperView {
    
    typealias Model = TabModel<Content>
    typealias MakeContentView = (TabState<Content>, @escaping (TabEvent<Content>) -> Void) -> ContentView
}
