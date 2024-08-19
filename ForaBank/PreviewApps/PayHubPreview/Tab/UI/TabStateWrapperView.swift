//
//  TabStateWrapperView.swift
//  PayHubPreview
//
//  Created by Igor Malyarov on 16.08.2024.
//

import SwiftUI

struct TabStateWrapperView<Content: View>: View {
    
    @StateObject private var model: Model
    
    private let makeContent: MakeContent
    
    init(
        model: Model,
        @ViewBuilder makeContent: @escaping MakeContent
    ) {
        self._model = .init(wrappedValue: model)
        self.makeContent = makeContent
    }
    
    var body: some View {
        
        makeContent(model.state, model.event(_:))
    }
}

extension TabStateWrapperView {
    
    typealias Model = TabModel
    typealias MakeContent = (TabState, @escaping (TabEvent) -> Void) -> Content
}
