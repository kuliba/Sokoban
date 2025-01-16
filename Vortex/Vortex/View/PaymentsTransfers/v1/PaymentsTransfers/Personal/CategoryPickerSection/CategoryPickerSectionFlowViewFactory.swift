//
//  CategoryPickerSectionFlowViewFactory.swift
//
//
//  Created by Igor Malyarov on 26.08.2024.
//

import PayHub
import SwiftUI

struct CategoryPickerSectionFlowViewFactory<ContentView, Destination, DestinationView> {
    
    let makeAlert: MakeAlert
    let makeContentView: MakeContentView
    let makeDestinationView: MakeDestinationView
}

extension CategoryPickerSectionFlowViewFactory {
    
    typealias MakeAlert = (SelectedCategoryFailure) -> Alert
    typealias MakeContentView = () -> ContentView
    typealias MakeDestinationView = (Destination) -> DestinationView
}
