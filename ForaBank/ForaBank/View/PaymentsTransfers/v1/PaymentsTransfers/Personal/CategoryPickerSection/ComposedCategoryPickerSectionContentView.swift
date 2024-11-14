//
//  ComposedCategoryPickerSectionContentView.swift
//  ForaBank
//
//  Created by Igor Malyarov on 13.11.2024.
//

import PayHub
import PayHubUI
import RxViewModel
import SwiftUI

struct ComposedCategoryPickerSectionContentView<ContentView>: View
where ContentView: View {
    
    let content: Content
    let makeContentView: MakeContentView
    
    var body: some View {
        
        RxWrapperView(
            model: content,
            makeContentView: makeContentView
        )
    }
}

extension ComposedCategoryPickerSectionContentView {
    
    typealias Domain = CategoryPickerDomain<ServiceCategory, QRNavigationComposer.NotifyEvent, CategoryPickerSectionNavigation>.ContentDomain
    typealias Content = Domain.Content
    
    typealias MakeContentView = (Domain.State, @escaping (Domain.Event) -> Void) -> ContentView
}
