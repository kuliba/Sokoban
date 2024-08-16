//
//  PayHubViewFactory.swift
//  PayHubPreview
//
//  Created by Igor Malyarov on 16.08.2024.
//

import SwiftUI

struct PayHubViewFactory<ContentView> {
    
    let makeContent: MakeContent
}

extension PayHubViewFactory {
    
    typealias MakeContent = (PayHubContent) -> ContentView
}
