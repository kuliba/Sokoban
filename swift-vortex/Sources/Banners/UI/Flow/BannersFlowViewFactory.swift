//
//  BannersFlowViewFactory.swift
//
//
//  Created by Andryusina Nataly on 11.09.2024.
//

import SwiftUI

public struct BannersFlowViewFactory<ContentView>
where ContentView: View {
    
    public let makeContentView: MakeContentView
    
    public init(
        @ViewBuilder makeContentView: @escaping MakeContentView
    ) {
        self.makeContentView = makeContentView
    }
}

public extension BannersFlowViewFactory {
    
    typealias MakeContentView = () -> ContentView
}
