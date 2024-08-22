//
//  CategoryPickerSectionContentWrapperView.swift
//  PayHubPreview
//
//  Created by Igor Malyarov on 21.08.2024.
//

import SwiftUI

public struct CategoryPickerSectionContentWrapperView<ContentView, ServiceCategory>: View
where ContentView: View {
    
    @ObservedObject private var model: Model
    
    private let makeContentView: MakeContentView
    
    public init(
        model: Model, 
        makeContentView: @escaping MakeContentView
    ) {
        self.model = model
        self.makeContentView = makeContentView
    }
    
    public var body: some View {
        
        makeContentView(model.state, model.event(_:))
    }
}

public extension CategoryPickerSectionContentWrapperView {
    
    typealias Model = CategoryPickerSectionContent<ServiceCategory>
    typealias State = CategoryPickerSectionState<ServiceCategory>
    typealias Event = CategoryPickerSectionEvent<ServiceCategory>
    typealias MakeContentView = (State, @escaping (Event) -> Void) -> ContentView
}
