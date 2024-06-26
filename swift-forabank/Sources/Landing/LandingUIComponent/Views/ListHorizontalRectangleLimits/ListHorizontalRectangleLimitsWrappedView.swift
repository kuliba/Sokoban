//
//  ListHorizontalRectangleLimitsWrappedView.swift
//  
//
//  Created by Andryusina Nataly on 21.06.2024.
//

import RxViewModel
import SwiftUI
import Tagged

public typealias ListHorizontalRectangleLimitsViewModel = RxViewModel<ListHorizontalRectangleLimitsState, ListHorizontalRectangleLimitsEvent, ListHorizontalRectangleLimitsEffect>

struct ListHorizontalRectangleLimitsWrappedView: View {
    
    @ObservedObject var model: ListHorizontalRectangleLimitsViewModel
    let factory: ViewFactory
    let config: ListHorizontalRectangleLimitsView.Config
    
    public init(
        model: ListHorizontalRectangleLimitsViewModel,
        factory: ViewFactory,
        config: ListHorizontalRectangleLimitsView.Config
    ) {
        self.model = model
        self.factory = factory
        self.config = config
    }

    public var body: some View {
        
        ListHorizontalRectangleLimitsView(
            state: model.state,
            event: model.event(_:),
            factory: factory,
            config: config)
    }
}
