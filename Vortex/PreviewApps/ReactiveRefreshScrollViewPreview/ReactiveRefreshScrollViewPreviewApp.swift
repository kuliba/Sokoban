//
//  ReactiveRefreshScrollViewPreviewApp.swift
//  ReactiveRefreshScrollViewPreview
//
//  Created by Igor Malyarov on 01.03.2025.
//

import SwiftUI
import UIPrimitives
import VortexTools

@main
struct ReactiveRefreshScrollViewPreviewApp: App {
    
    let model: ItemsModel
    let scrollModel: ReactiveRefreshScrollViewModel
    
    init() {
        
        let model = ItemsModel()
        let scrollModel = ReactiveRefreshScrollViewModel(
            config: .preview,
            scheduler: .main,
            refresh: model.addItem
        )
        
        self.model = model
        self.scrollModel = scrollModel
    }
    
    var body: some Scene {
        
        WindowGroup {
            
            ContentView(model: model, scrollModel: scrollModel)
        }
    }
}

extension SwipeToRefreshConfig {
    
    static let preview: Self = .init(
        threshold: 100,
        debounce: .seconds(2)
    )
}
