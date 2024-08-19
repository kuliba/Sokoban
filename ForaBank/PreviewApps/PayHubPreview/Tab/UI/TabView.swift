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
                get: { state },
                set: { event(.switchTo($0)) }
            )
        ) {
            ForEach(TabState.allCases, id: \.self, content: navWrapped)
        }
        .animation(.easeInOut, value: state)
    }
}

extension TabView {
    
    typealias State = TabState
    typealias Event = TabEvent
    typealias Factory = TabViewFactory<Content>
}

extension TabView {
    
    func navWrapped(
        _ tab: State
    ) -> some View {
        
        NavigationView {
            
            factory.makeContent(tab)
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .tabItem {
            
            Label(tab.tabTitle, systemImage: tab.systemImage)
        }
        .tag(tab)
    }
}

extension TabState {
    
    var tabTitle: String {
        
        switch self {
        case .noLatest:     return "No Latest"
        case .noCategories: return "No Categories"
        case .noBoth:       return "No Both"
        case .okEmpty:      return "OK Empty"
        case .ok:           return "OK"
        }
    }
    
    var systemImage: String {
        
        switch self {
        case .noLatest:     return "cloud.sun.rain"
        case .noCategories: return "cloud.bolt.rain"
        case .noBoth:       return "exclamationmark.circle"
        case .okEmpty:      return "sun.max.trianglebadge.exclamationmark"
        case .ok:           return "sun.max"
        }
    }
}
