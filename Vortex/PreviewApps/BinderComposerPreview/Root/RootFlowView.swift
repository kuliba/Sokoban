//
//  RootFlowView.swift
//  BinderComposerPreview
//
//  Created by Igor Malyarov on 14.12.2024.
//

import SwiftUI

struct RootFlowView<ContentView: View>: View {
    
    let state: State
    let event: (Event) -> Void
    let contentView: () -> ContentView
    
    var body: some View {
        
        contentView()
        
    }
}

extension RootFlowView {
    
    typealias State = RootDomain.FlowDomain.State
    typealias Event = RootDomain.FlowDomain.Event
}
