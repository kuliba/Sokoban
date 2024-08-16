//
//  ContentView.swift
//  PayHubPreview
//
//  Created by Igor Malyarov on 14.08.2024.
//

import SwiftUI

struct ContentView: View {
    
    var body: some View {
        
        TabWrapperView(
            model: .init(), 
            factory: .init(
                makeContent: { Text("TBD: \($0.tabTitle)") }
            )
        )
    }
}

private extension TabState {
    
    var loadResult: PayHubEffectHandler.MicroServices.LoadResult {
        
        switch self {
        case .noLatest:
            return .failure(NSError(domain: "Error", code: -1))
        case .noCategories:
            return .failure(NSError(domain: "Error", code: -1))
        case .noBoth:
            return .failure(NSError(domain: "Error", code: -1))
        case .okEmpty:
            return .success([])
        case .ok:
            return .success(.preview)
        }
    }
}

extension Array where Element == Latest {
    
    static let preview: Self = [
        .init(id: UUID().uuidString),
        .init(id: UUID().uuidString),
    ]
}

#Preview {
    ContentView()
}
