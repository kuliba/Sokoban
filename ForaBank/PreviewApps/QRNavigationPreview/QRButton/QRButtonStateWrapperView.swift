//
//  QRButtonStateWrapperView.swift
//  QRNavigationPreview
//
//  Created by Igor Malyarov on 30.10.2024.
//

import PayHubUI
import SwiftUI

struct QRButtonStateWrapperView: View {
    
    @StateObject var flow: QRButtonDomain.FlowDomain.Flow
    
    var body: some View {
        
        QRButtonView(state: flow.state, event: flow.event)
    }
}

#Preview {
    
    QRButtonStateWrapperView(flow: Node.preview().model)
}
