//
//  Composer.swift
//  FactoryBasedPreview
//
//  Created by Igor Malyarov on 24.04.2024.
//

import SwiftUI

final class Composer {}

extension Composer {
    
    func makeContentViewFactory(
    ) -> ContentViewFactory<RootView> {
        
        .init(makeRootView: makeRootView)
    }
}

extension Composer {
    
    typealias RootView = Text
}

private extension Composer {
    
    func makeRootView() -> RootView {
        
        Text("Root View here.")
    }
}
