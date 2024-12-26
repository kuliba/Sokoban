//
//  ContentViewFactory.swift
//  FactoryBasedPreview
//
//  Created by Igor Malyarov on 24.04.2024.
//

import SwiftUI

struct ContentViewFactory<RootView>
where RootView: View {
    
    let makeRootView: (RootState) -> RootView
}
