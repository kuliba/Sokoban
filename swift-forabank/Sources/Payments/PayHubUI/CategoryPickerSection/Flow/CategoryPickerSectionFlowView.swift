//
//  CategoryPickerSectionFlowView.swift
//
//
//  Created by Igor Malyarov on 26.08.2024.
//

import PayHub
import SwiftUI

public struct CategoryPickerSectionFlowView<ContentView, DestinationView, Category, CategoryModel, CategoryList>: View
where ContentView: View,
      DestinationView: View {
    
    let state: State
    let event: (Event) -> Void
    let factory: Factory
    
    public init(
        state: State,
        event: @escaping (Event) -> Void,
        factory: Factory
    ) {
        self.state = state
        self.event = event
        self.factory = factory
    }
    
    public var body: some View {
        
        factory.makeContentView()
            .navigationDestination(
                destination: state.destination,
                dismiss: { event(.select(nil)) },
                content: factory.makeDestinationView
            )
    }
}

public extension CategoryPickerSectionFlowView {
    
    typealias State = CategoryPickerSectionFlowState<CategoryModel, CategoryList>
    typealias Event = CategoryPickerSectionFlowEvent<Category, CategoryModel, CategoryList>
    typealias Factory = CategoryPickerSectionFlowViewFactory<ContentView, DestinationView, CategoryModel, CategoryList>
}

extension CategoryPickerSectionDestination: Identifiable {
    
    public var id: ID {
        
        switch self {
        case .category: return .category
        case .list:     return .list
        }
    }
    
    public enum ID: Hashable {
        
        case category, list
    }
}
