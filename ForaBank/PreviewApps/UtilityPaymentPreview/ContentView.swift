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
        
        PaymentsTransfersView(
            viewModel: .default(flow: flow),
            factory: .init()
        )
        .toolbar {
            ToolbarItem(
                placement: .topBarLeading,
                content: settingsButton
            )
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
        
        Button {
            isShowingSettings = false
        } label: {
            Image(systemName: "xmark")
        }
        .padding(.horizontal)
    }
}

struct ContentView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        NavigationView {
            
            ContentView()
                .navigationTitle("Payments Transfers")
                .navigationBarTitleDisplayMode(.inline)
        }
    }
}
