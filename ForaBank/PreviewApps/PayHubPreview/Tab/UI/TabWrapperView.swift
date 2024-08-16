//
//  TabWrapperView.swift
//  PayHubPreview
//
//  Created by Igor Malyarov on 16.08.2024.
//

import SwiftUI

struct TabWrapperView<Content: View>: View {
    
    @StateObject private var model: Model
    
    private let factory: Factory
    
    init(
        model: Model,
        factory: Factory
    ) {
        self._model = .init(wrappedValue: model)
        self.factory = factory
    }
    
    var body: some View {
        
        TabView(
            state: model.state,
            event: model.event(_:),
            factory: factory
        )
    }
}

extension TabWrapperView {
    
    typealias Model = TabModel
    typealias Factory = TabViewFactory<Content>
}
