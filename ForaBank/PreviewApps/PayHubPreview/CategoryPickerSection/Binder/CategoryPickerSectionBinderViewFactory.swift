//
//  CategoryPickerSectionBinderViewFactory.swift
//  PayHubPreview
//
//  Created by Igor Malyarov on 21.08.2024.
//

import SwiftUI

struct CategoryPickerSectionBinderViewFactory<Content, Destination, DestinationView> {
    
    let makeContentView: MakeContentView
    let makeDestinationView: MakeDestinationView
}

extension CategoryPickerSectionBinderViewFactory {
    
    typealias MakeContentView = (CategoryPickerSectionContent) -> Content
    typealias MakeDestinationView = (Destination) -> DestinationView
}

