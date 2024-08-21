//
//  CategoryPickerSectionContentView.swift
//  PayHubPreview
//
//  Created by Igor Malyarov on 21.08.2024.
//

import SwiftUI

struct CategoryPickerSectionContentView: View {
    
    let state: State
    let event: (Event) -> Void
    
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

extension CategoryPickerSectionContentView {
    
    typealias State = CategoryPickerSectionState
    typealias Event = CategoryPickerSectionEvent
}
