//
//  CategoryPickerSectionBinderView.swift
//  PayHubPreview
//
//  Created by Igor Malyarov on 21.08.2024.
//

import SwiftUI

struct CategoryPickerSectionBinderView<ContentView, Destination, DestinationView>: View
where ContentView: View,
      DestinationView: View {
    
    @ObservedObject private var content: CategoryPickerSectionContent
    // @ObservedObject private var flow: CategoryPickerSectionFlow
    
    private let factory: Factory
    
    init(
        binder: CategoryPickerSectionBinder,
        factory: Factory
    ) {
        self._content = .init(initialValue: binder.content)
        // self._flow = .init(initialValue: binder.flow)
        self.factory = factory
    }
    
    var body: some View {
        
        factory.makeContentView(content)
            .onFirstAppear { content.event(.load) }
        //    .navigationDestination(
        //        destination: flow.state.selected,
        //        dismiss: { content.event(.select(nil)) },
        //        content: factory.makeDestinationView
        //    )
    }
}

extension CategoryPickerSectionBinderView {
    
    typealias Factory = CategoryPickerSectionBinderViewFactory<ContentView, Destination, DestinationView>
}
