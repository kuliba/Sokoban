//
//  CategoryPickerSectionFlowViewFactory.swift
//  
//
//  Created by Igor Malyarov on 26.08.2024.
//

import PayHub
import SwiftUI

public struct CategoryPickerSectionFlowViewFactory<ContentView, DestinationView, SelectedCategory, CategoryList> {
    
    let makeContentView: MakeContentView
    let makeDestinationView: MakeDestinationView
    
    public init(
        makeContentView: @escaping MakeContentView,
        makeDestinationView: @escaping MakeDestinationView
    ) {
        self.makeContentView = makeContentView
        self.makeDestinationView = makeDestinationView
    }
}

public extension CategoryPickerSectionFlowViewFactory {
    
    typealias MakeContentView = () -> ContentView
    
    typealias Destination = CategoryPickerSectionFlowState<SelectedCategory, CategoryList>.Destination
    typealias MakeDestinationView = (Destination) -> DestinationView
}
