//
//  TabViewFactory.swift
//  PayHubPreview
//
//  Created by Igor Malyarov on 16.08.2024.
//

import SwiftUI

struct TabViewFactory<Content: View> {
    
    let makeContent: MakeContent
}

extension TabViewFactory {
    
    typealias MakeContent = (TabState) -> Content
}
