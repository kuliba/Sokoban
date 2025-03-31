//
//  SwiftUIView.swift
//  
//
//  Created by Igor Malyarov on 30.03.2025.
//

import SwiftUI

/// Inspired by Apple Docs [Store observable objects](https://developer.apple.com/documentation/swiftui/state#Store-observable-objects)
/// A State property always instantiates its default value when SwiftUI instantiates the view. For this reason, avoid side effects and performance-intensive work when initializing the default value. For example, if a view updates frequently, allocating a new default object each time the view initializes can become expensive. Instead, you can defer the creation of the object using the `task(priority:_:) `modifier, which is called only once when the view first appears.
public struct WrapperView<Model, Content: View>: View {
    
    @State private var model: Model?
    
    private let factory: () -> Model
    private let content: (Model) -> Content
    
    public init(
        factory: @escaping () -> Model,
        content: @escaping (Model) -> Content
    ) {
        self.factory = factory
        self.content = content
    }
    
    public var body: some View {
        
        switch model {
        case .none:
            Color.clear
                .task { model = factory() }
            
        case let .some(model):
            content(model)
        }
    }
}
