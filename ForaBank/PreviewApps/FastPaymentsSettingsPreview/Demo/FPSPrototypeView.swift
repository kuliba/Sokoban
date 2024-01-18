//
//  FPSPrototypeView.swift
//  FastPaymentsSettingsPreview
//
//  Created by Igor Malyarov on 12.01.2024.
//

import FastPaymentsSettings
import SwiftUI

struct FPSPrototypeView: View {
    
    @State private var flowStub: FlowStub
    @State private var isShowingFlowStubOptions = false
    
    init() {
        let flowStub: FlowStub = .preview
        self.flowStub = flowStub
    }
    
    var body: some View {
        
        UserAccountView(viewModel: .preview(
            route: .init(),
            flowStub: flowStub
        ))
        .overlay(alignment: .topTrailing, content: flowStubButton)
        .fullScreenCover(isPresented: $isShowingFlowStubOptions, content: fullScreenCover)
    }
    
    private func flowStubButton() -> some View {
        
        Button("Flow") {
            
            isShowingFlowStubOptions = true
        }
        .padding(.horizontal)
    }
    
    private func fullScreenCover() -> some View {
        
        FlowStubSettingsView(
            flowStub: flowStub,
            commit: {
                
                flowStub = $0
                isShowingFlowStubOptions = false
            }
        )
    }
}

struct FPSPrototypeView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        FPSPrototypeView()
    }
}
