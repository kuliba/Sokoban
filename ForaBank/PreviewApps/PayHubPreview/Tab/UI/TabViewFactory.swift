//
//  TabViewFactory.swift
//  PayHubPreview
//
//  Created by Igor Malyarov on 16.08.2024.
//

import SwiftUI

struct TabViewFactory<Content, ContentView: View> {
    
    let makeContentView: MakeContentView
}

extension TabViewFactory {
    
    typealias MakeContentView = (Content) -> ContentView
}
