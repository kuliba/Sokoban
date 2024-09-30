//
//  BannersFlowView.swift
//  
//
//  Created by Andryusina Nataly on 11.09.2024.
//

import SwiftUI

public struct BannersFlowView<Content>: View
where Content: View {
    
    private let state: State
    private let event: (Event) -> Void
    private let factory: Factory
    
    public init(
        state: State,
        event: @escaping (Event) -> Void,
        factory: Factory
    ) {
        self.state = state
        self.event = event
        self.factory = factory
    }
    
    public var body: some View {
        
        factory.makeContentView()
    }
}

public extension BannersFlowView {
    
    typealias State = BannersFlowState
    typealias Event = BannersFlowEvent
    typealias Factory = BannersFlowViewFactory<Content>
}
