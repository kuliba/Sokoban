//
//  CategoryPickerSectionFlowViewFactory.swift
//
//
//  Created by Igor Malyarov on 26.08.2024.
//

import PayHub
import SwiftUI

struct CategoryPickerSectionFlowViewFactory<ContentView, DestinationView, FullScreenCoverView> {
    
    let makeAlert: MakeAlert
    let makeContentView: MakeContentView
    let makeDestinationView: MakeDestinationView
    let makeFullScreenCoverView: MakeFullScreenCoverView
}

extension CategoryPickerSectionFlowViewFactory {
    
    typealias MakeAlert = (SelectedCategoryFailure) -> Alert
    typealias MakeContentView = () -> ContentView
    typealias MakeDestinationView = (CategoryPickerSectionNavigation.Destination) -> DestinationView
    typealias MakeFullScreenCoverView = (CategoryPickerSectionNavigation.FullScreenCover) -> FullScreenCoverView
}
