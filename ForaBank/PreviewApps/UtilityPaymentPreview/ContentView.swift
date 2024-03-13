//
//  ContentView.swift
//  UtilityPaymentPreview
//
//  Created by Igor Malyarov on 03.03.2024.
//

import SwiftUI

struct ContentView: View {
    
    @State private var tab: Tab = .settings
    @State private var flow: Flow = .happy
    
    var body: some View {
        
        tabView()
    }
}

private extension ContentView {
    
    func tabView() -> some View {
        
        TabView(selection: $tab) {
            
            mainView()
                .taggedTabItem(.main)
            
            paymentsView()
                .taggedTabItem(.payments)
            
            chatView()
                .taggedTabItem(.chat)
            
            settingsView()
                .taggedTabItem(.settings)
        }
        .animation(.default, value: tab)
    }
    
    func mainView() -> some View {
        
        VStack(spacing: 32) {
            
            Text("Main View")
                .font(.title.bold())
            
            Button("Payments") { tab = .payments }
        }
    }
    
    func paymentsView() -> some View {
        
        PaymentsTransfersView(
            viewModel: .default(flow: flow),
            factory: .init()
        )
    }
    
    func chatView() -> some View {
        
        VStack(spacing: 32) {
            
            Text("Chat")
                .font(.title.bold())
            
            Label("Under Construction", systemImage: "wrench.and.screwdriver")
        }
    }
    
    func settingsView() -> some View {
        
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
        
        Button("Done") { tab = .payments }
    }
}

extension ContentView {
    
    enum Tab: String {
        
        case main, payments, chat, settings
    }
}

private extension ContentView.Tab {
    
    var systemImage: String {
        
        switch self {
        case .main:
            return "book.pages"
        case .payments:
            return "rublesign.arrow.circlepath"
        case .chat:
            return "bubble"
        case .settings:
            return "slider.horizontal.3"
        }
    }
}

private extension View {
    
    func taggedTabItem(
        _ tab: ContentView.Tab
    ) -> some View {
        
        self
            .tabItem {
                
                Label(
                    tab.rawValue.capitalized,
                    systemImage: tab.systemImage
                )
            }
            .tag(tab)
    }
}

struct ContentView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        ContentView()
    }
}
