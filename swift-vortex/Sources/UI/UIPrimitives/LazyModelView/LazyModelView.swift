//
//  LazyModelView.swift
//
//
//  Created by Igor Malyarov on 30.03.2025.
//

import SwiftUI

/// A view that lazily initializes a model when it first appears and provides it to its content.
///
/// `LazyModelView` addresses a common SwiftUI performance problem where `@State` properties
/// are re-initialized every time a view is reconstructed. Instead of creating the model
/// immediately, this view:
/// 1. Displays a placeholder initially
/// 2. Uses a task to create the model only when the view appears
/// 3. Renders the actual content once the model is available
///
/// - Note: This pattern follows Apple's recommendation for deferring expensive object creation
///   as described in [Store observable objects](https://developer.apple.com/documentation/swiftui/state#Store-observable-objects)
///
///     A State property always instantiates its default value when SwiftUI instantiates the view. For this reason, avoid side effects and performance-intensive work when initializing the default value. For example, if a view updates frequently, allocating a new default object each time the view initializes can become expensive. Instead, you can defer the creation of the object using the `task(priority:_:) `modifier, which is called only once when the view first appears.
///
/// - Important: The model is initialized exactly once when the view first appears,
///   using SwiftUI's `task` modifier. This avoids redundant initializations during view updates.
public struct LazyModelView<Model, Content: View>: View {
    
    @State private var model: Model?
    
    private let factory: () -> Model
    private let content: (Model) -> Content
    
    /// Creates a new view that lazily initializes its model.
    ///
    /// - Parameters:
    ///   - factory: A closure that creates the model. This is called only once when the view first appears.
    ///   - content: A closure that creates the view content using the initialized model.
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
