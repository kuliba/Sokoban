//
//  ContentView.swift
//  UtilityPaymentPreview
//
//  Created by Igor Malyarov on 03.03.2024.
//

import SwiftUI
import UIPrimitives

struct ContentView: View {
    
    @State private var flow: Flow = .happy
    @State private var isShowingSettings = false
    
    var body: some View {
        
        ZStack(alignment: .bottomLeading) {
            
            PaymentsTransfersView(
                viewModel: .default(flow: flow),
                factory: .init()
            )
            
            settingsButton()
        }
        .fullScreenCover(
            isPresented: $isShowingSettings,
            content: fullScreenCover
        )
    }
    
    private func settingsButton() -> some View {
        
        Button {
            isShowingSettings = true
        } label: {
            Image(systemName: "slider.horizontal.3")
                .imageScale(.large)
                .frame(width: 44, height: 44)
        }
        .padding(.horizontal)
    }
    
    private func fullScreenCover() -> some View {
        
        NavigationView {
            
            FlowSettingsView(flow: $flow)
                .navigationTitle("Flow Settings")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(content: closeSettingsButton)
                }
        }
    }
    
    private func closeSettingsButton() -> some View {
        
        Button("Done") { isShowingSettings = false }
            .padding(.horizontal)
    }
}

struct ContentView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        ContentView()
    }
}
