//
//  OperationPickerContentWrapperView.swift
//  ForaBank
//
//  Created by Igor Malyarov on 16.08.2024.
//

import PayHub
import SwiftUI

struct OperationPickerContentWrapperView<ContentView>: View
where ContentView: View {
    
    @ObservedObject private var model: Model
    
    private let makeContentView: MakeContentView
    
    init(
        model: Model,
        makeContentView: @escaping MakeContentView
    ) {
        self.model = model
        self.makeContentView = makeContentView
    }
    
    var body: some View {
        
        makeContentView(model.state, model.event)
    }
}

extension OperationPickerContentWrapperView {
    
    typealias State = OperationPickerState
    typealias Event = OperationPickerEvent
    typealias MakeContentView = (State, @escaping (Event) -> Void) -> ContentView
    typealias Model = OperationPickerContent
}
