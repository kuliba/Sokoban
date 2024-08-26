//
//  TabView.swift
//  PayHubPreview
//
//  Created by Igor Malyarov on 16.08.2024.
//

import SwiftUI

struct TabView<Content: View>: View {
    
    let state: State
    let event: (Event) -> Void
    let factory: Factory
    
    var body: some View {
        
        SwiftUI.TabView(
            selection: .init(
                get: { state.selected },
                set: { event(.select($0)) }
            )
        ) {
            navWrapped(state.noLatest, tab: .noLatest)
            navWrapped(state.noCategories, tab: .noCategories)
            navWrapped(state.noBoth, tab: .noBoth)
            navWrapped(state.ok, tab: .ok)
        }
        .animation(.easeInOut, value: state.selected)
    }
}

extension TabView {
    
    typealias State = TabState
    typealias Event = TabEvent
    typealias Factory = TabViewFactory<Content>
}

extension TabView {
    
    func navWrapped(
        _ binder: State.Binder,
        tab: State.Selected
    ) -> some View {
        
        NavigationView {
            
            factory.makeBinderView(binder)
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .tabItem {
            
            Label(tab.tabTitle, systemImage: tab.systemImage)
        }
        .tag(tab)
    }
}

extension TabState.Selected {
    
    var tabTitle: String {
        
        switch self {
        case .noLatest:     return "No Latest"
        case .noCategories: return "No Categories"
        case .noBoth:       return "No Both"
        case .ok:           return "OK"
        }
    }
    
    var systemImage: String {
        
        switch self {
        case .noLatest:     return "cloud.sun.rain"
        case .noCategories: return "cloud.bolt.rain"
        case .noBoth:       return "exclamationmark.circle"
        case .ok:           return "sun.max"
        }
    }
}
