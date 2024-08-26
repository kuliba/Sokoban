//
//  OperationPickerContentWrapperView.swift
//  ForaBank
//
//  Created by Igor Malyarov on 16.08.2024.
//

import PayHub
import SwiftUI

public struct OperationPickerContentWrapperView<ContentView, Latest>: View
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
        
        makeContentView(model.state, model.event)
    }
}

public extension OperationPickerContentWrapperView {
    
    typealias State = OperationPickerState<Latest>
    typealias Event = OperationPickerEvent<Latest>
    typealias MakeContentView = (State, @escaping (Event) -> Void) -> ContentView
    typealias Model = OperationPickerContent<Latest>
}
