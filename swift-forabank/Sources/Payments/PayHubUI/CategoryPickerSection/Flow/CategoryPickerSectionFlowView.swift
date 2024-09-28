//
//  CategoryPickerSectionFlowView.swift
//
//
//  Created by Igor Malyarov on 26.08.2024.
//

import PayHub
import SwiftUI

public struct CategoryPickerSectionFlowView<ContentView, DestinationView, Category, SelectedCategory, Failure, CategoryList>: View
where ContentView: View,
      DestinationView: View,
      Failure: Error & Identifiable {
    
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
            .alert(
                item: failure,
                content: factory.makeAlert
            )
            .navigationDestination(
                destination: destination,
                dismiss: { event(.dismiss) },
                content: factory.makeDestinationView
            )
    }
}

public extension CategoryPickerSectionFlowView {
    
    typealias Domain = CategoryPickerSectionDomain<Category, SelectedCategory, CategoryList, Failure>
    
    typealias State = Domain.FlowState
    typealias Event = Domain.FlowEvent
    typealias Factory = CategoryPickerSectionFlowViewFactory<ContentView, DestinationView, SelectedCategory, Failure, CategoryList>
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

private extension CategoryPickerSectionFlowView {
    
    var failure: Failure? {
        
        guard case let .failure(failure) = state.navigation
        else { return nil }
        
        return failure
    }
    
    var destination: CategoryPickerSectionDestination<SelectedCategory, CategoryList>? {
        
        guard case let .destination(destination) = state.navigation
        else { return nil }
        
        return destination
    }
}
