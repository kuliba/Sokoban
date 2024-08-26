//
//  CategoryPickerSectionBinderView.swift
//
//
//  Created by Igor Malyarov on 21.08.2024.
//

import SwiftUI

public struct CategoryPickerSectionBinderView<Category, CategoryModel, CategoryList, ContentView, Destination, DestinationView>: View
where ContentView: View,
      DestinationView: View {
    
    @ObservedObject private var content: Content
    // @ObservedObject private var flow: CategoryPickerSectionFlow
    
    private let factory: Factory
    
    public init(
        binder: Binder,
        factory: Factory
    ) {
        self._content = .init(initialValue: binder.content)
        // self._flow = .init(initialValue: binder.flow)
        self.factory = factory
    }
    
    public var body: some View {
        
        factory.makeContentView(content)
            .onFirstAppear { content.event(.load) }
        //    .navigationDestination(
        //        destination: flow.state.selected,
        //        dismiss: { content.event(.select(nil)) },
        //        content: factory.makeDestinationView
        //    )
    }
}

public extension CategoryPickerSectionBinderView {
    
    typealias Binder = CategoryPickerSectionBinder<Category, CategoryModel, CategoryList>
    typealias Content = CategoryPickerSectionContent<Category>
    typealias Factory = CategoryPickerSectionBinderViewFactory<ContentView, Destination, DestinationView, Category>
}
