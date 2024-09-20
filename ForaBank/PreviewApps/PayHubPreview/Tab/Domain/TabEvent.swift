//
//  TabEvent.swift
//  PayHubPreview
//
//  Created by Igor Malyarov on 16.08.2024.
//

enum TabEvent<Content>: Equatable {
    
    case select(TabState<Content>.Selected)
}
