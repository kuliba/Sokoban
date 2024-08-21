//
//  CategoryPickerSectionContentWrapperView.swift
//  PayHubPreview
//
//  Created by Igor Malyarov on 21.08.2024.
//

import SwiftUI

struct CategoryPickerSectionContentWrapperView<ContentView>: View
where ContentView: View {
    
    @ObservedObject var model: Model
    
    let makeContentView: MakeContentView
    
    var body: some View {
        
        makeContentView(model.state, model.event(_:))
    }
}

extension CategoryPickerSectionContentWrapperView {
    
    typealias Model = CategoryPickerSectionContent
    typealias State = CategoryPickerSectionState
    typealias Event = CategoryPickerSectionEvent
    typealias MakeContentView = (State, @escaping (Event) -> Void) -> ContentView
}
