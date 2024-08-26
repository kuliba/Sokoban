//
//  PaymentsTransfersToolbarContentWrapperView.swift
//
//
//  Created by Igor Malyarov on 23.08.2024.
//

import PayHub
import SwiftUI

public struct PaymentsTransfersToolbarContentWrapperView<ContentView>: View
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

public extension PaymentsTransfersToolbarContentWrapperView {
    
    typealias Model = PaymentsTransfersToolbarContent
    typealias State = PaymentsTransfersToolbarState
    typealias Event = PaymentsTransfersToolbarEvent
    typealias MakeContentView = (State, @escaping (Event) -> Void) -> ContentView
}
