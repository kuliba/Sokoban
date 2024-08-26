//
//  CategoryPickerSectionBinderViewFactory.swift
//
//
//  Created by Igor Malyarov on 21.08.2024.
//

import SwiftUI

public struct CategoryPickerSectionBinderViewFactory<ContentView, Destination, DestinationView, Category> {
    
    public let makeContentView: MakeContentView
    public let makeDestinationView: MakeDestinationView
    
    public init(
        makeContentView: @escaping MakeContentView,
        makeDestinationView: @escaping MakeDestinationView
    ) {
        self.makeContentView = makeContentView
        self.makeDestinationView = makeDestinationView
    }
}

public extension CategoryPickerSectionBinderViewFactory {
    
    typealias Content = CategoryPickerSectionContent<Category>
    typealias MakeContentView = (Content) -> ContentView
    typealias MakeDestinationView = (Destination) -> DestinationView
}
