//
//  ContentView.swift
//  UtilityPaymentPreview
//
//  Created by Igor Malyarov on 03.03.2024.
//

import Combine
import SwiftUI

struct ContentState {
    
    var tab: ContentView.Tab = .payments
    var flowSettings: FlowSettings = .happy
    var isShowingSpinner = false
}

final class ContentViewModel: ObservableObject {
    
    @Published var state: ContentState
    
    private(set) var paymentsTransfersViewModel: PaymentsTransfersViewModel
    private var cancellables = Set<AnyCancellable>()
    
    init(state: ContentState = .init()) {
        
        self.state = state
        self.paymentsTransfersViewModel = .default(flowSettings: state.flowSettings)
        let rootActions = RootActions(
            spinner: .init(
                hide: {
                    
                    DispatchQueue.main.async { [weak self] in
                        
                        self?.state.isShowingSpinner = false
                    }
                },
                show: {
                    
                    DispatchQueue.main.async { [weak self] in
                        
                        self?.state.isShowingSpinner = true
                    }
                }
            )
        )
        self.paymentsTransfersViewModel.rootActions = rootActions
        
        $state
            .map(\.flowSettings)
            .removeDuplicates()
            .sink { [weak self] in
                
                guard let self else { return }
                
                print("set PaymentsTransfersViewModel")
                paymentsTransfersViewModel = .default(flowSettings: $0)
                paymentsTransfersViewModel.rootActions = rootActions
            }
            .store(in: &cancellables)
    }
    
    deinit {
        
        print("deinit: \(type(of: Self.self))")
    }
}

struct ContentView: View {
    
    @ObservedObject var viewModel: ContentViewModel
    
    var body: some View {
        
        ZStack {
            
            tabView()
            
            spinner()
                .ignoresSafeArea()
        }
    }
}

private extension ContentView {
    
    func tabView() -> some View {
        
        TabView(selection: $viewModel.state.tab) {
            
            mainView()
                .taggedTabItem(.main)
            
            paymentsView()
                .taggedTabItem(.payments)
            
            chatView()
                .taggedTabItem(.chat)
            
            settingsView()
                .taggedTabItem(.settings)
        }
        .animation(.default, value: viewModel.state.tab)
    }
    
    func mainView() -> some View {
        
        VStack(spacing: 32) {
            
            Text("Main View")
                .font(.title.bold())
            
            Button("Payments") { viewModel.state.tab = .payments }
        }
    }
    
    func paymentsView() -> some View {
        
        NavigationView {
            
            PaymentsTransfersView(
                viewModel: viewModel.paymentsTransfersViewModel,
                factory: .init()
            )
            .navigationViewStyle(StackNavigationViewStyle())
        }
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
            
            FlowSettingsView(flowSettings: $viewModel.state.flowSettings)
                .navigationTitle("Flow Settings")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(content: closeSettingsButton)
                }
        }
    }
    
    private func closeSettingsButton() -> some View {
        
        Button("Done") { viewModel.state.tab = .payments }
    }
    
    private func spinner() -> some View {
        
        ZStack {
            
            Color.black.opacity(0.5)
            
            ProgressView()
        }
        .ignoresSafeArea()
        .opacity(viewModel.state.isShowingSpinner ? 1 : 0)
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
        
        ContentView(viewModel: .init())
    }
}
