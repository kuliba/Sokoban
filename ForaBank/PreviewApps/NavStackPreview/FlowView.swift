//
//  FlowView.swift
//  NavStackPreview
//
//  Created by Igor Malyarov on 23.04.2024.
//

import SwiftUI

struct FlowView<Flow: View>: View {

    let makeFlow: () -> Flow
    
    var body: some View {
        
        makeFlow()
    }
}

#Preview {
    FlowView { Text("Flow View") }
}
