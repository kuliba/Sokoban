//
//  TabViewFactory.swift
//  PayHubPreview
//
//  Created by Igor Malyarov on 16.08.2024.
//

import SwiftUI

struct TabViewFactory<BinderView: View> {
    
    let makeBinderView: MakeBinderView
}

extension TabViewFactory {
    
    typealias MakeBinderView = (TabState.Binder) -> BinderView
}
