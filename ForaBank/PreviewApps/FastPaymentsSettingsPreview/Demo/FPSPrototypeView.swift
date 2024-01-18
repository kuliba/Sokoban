//
//  FPSPrototypeView.swift
//  FastPaymentsSettingsPreview
//
//  Created by Igor Malyarov on 12.01.2024.
//

import FastPaymentsSettings
import SwiftUI

struct FPSPrototypeView: View {
    
    @State private var flowStub: FlowStub?
    @State private var isShowingFlowStubOptions = false
    
    var body: some View {
        
        switcher()
            .fullScreenCover(isPresented: $isShowingFlowStubOptions, content: fullScreenCover)
    }
    
    @ViewBuilder
    private func switcher() -> some View {
        
        switch flowStub {
        case .none:
            flowStubButton("Select Flow")
                .font(.headline)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            
        case let .some(flowStub):
            
            UserAccountView(viewModel: .preview(
                route: .init(),
                flowStub: flowStub
            ))
            .overlay(alignment: .topTrailing) { flowStubButton("Flow") }
        }
    }
    
    private func flowStubButton(_ title: String) -> some View {
        
        Button(title) {
            
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
