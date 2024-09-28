//
//  CategoryPickerSectionFlowViewFactory.swift
//
//
//  Created by Igor Malyarov on 26.08.2024.
//

import PayHub
import SwiftUI

public struct CategoryPickerSectionFlowViewFactory<ContentView, DestinationView, SelectedCategory, Failure: Error, CategoryList> {
    
    let makeAlert: MakeAlert
    let makeContentView: MakeContentView
    let makeDestinationView: MakeDestinationView
    
    public init(
        makeAlert: @escaping MakeAlert,
        makeContentView: @escaping MakeContentView,
        makeDestinationView: @escaping MakeDestinationView
    ) {
        self.makeAlert = makeAlert
        self.makeContentView = makeContentView
        self.makeDestinationView = makeDestinationView
    }
}

public extension CategoryPickerSectionFlowViewFactory {
    
    typealias MakeAlert = (Failure) -> Alert
    
    typealias MakeContentView = () -> ContentView
    
    typealias Domain = CategoryPickerSectionDomain<Category, SelectedCategory, CategoryList, Failure>
    typealias Destination = Domain.FlowState.Destination
    typealias MakeDestinationView = (Destination) -> DestinationView
}
