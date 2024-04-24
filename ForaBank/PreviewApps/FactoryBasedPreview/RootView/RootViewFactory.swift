//
//  RootViewFactory.swift
//  FactoryBasedPreview
//
//  Created by Igor Malyarov on 24.04.2024.
//

import SwiftUI

struct RootViewFactory<Content, Spinner>
where Content: View,
      Spinner: View {
    
    let makeContent: MakeContent
    let makeSpinner: MakeSpinner
}

extension RootViewFactory {
    
    typealias MakeContent = (MainTabState, @escaping (SpinnerEvent) -> Void) -> Content
    typealias MakeSpinner = () -> Spinner
}
