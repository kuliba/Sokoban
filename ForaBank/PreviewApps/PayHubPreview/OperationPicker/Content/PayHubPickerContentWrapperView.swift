//
//  PayHubPickerContentWrapperView.swift
//  ForaBank
//
//  Created by Igor Malyarov on 16.08.2024.
//

import PayHub
import SwiftUI

struct PayHubPickerContentWrapperView<ContentView>: View
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

extension PayHubPickerContentWrapperView {
    
    typealias State = PayHubPickerState
    typealias Event = PayHubPickerEvent
    typealias MakeContentView = (State, @escaping (Event) -> Void) -> ContentView
    typealias Model = PayHubPickerContent
}
