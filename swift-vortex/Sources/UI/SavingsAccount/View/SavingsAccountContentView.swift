//
//  SavingsAccountContentView.swift
//
//
//  Created by Andryusina Nataly on 03.12.2024.
//

import SwiftUI

public struct SavingsAccountContentView<RefreshView, LandingView, Landing, InformerPayload>: View
where RefreshView: View,
      LandingView: View
{
    
    let state: State
    let event: (Event<Landing, InformerPayload>) -> Void
    let config: Config
    let factory: Factory
    
    public init(
        state: State,
        event: @escaping (Event<Landing, InformerPayload>) -> Void,
        config: Config,
        factory: Factory
    ) {
        self.state = state
        self.event = event
        self.config = config
        self.factory = factory
    }
    
    public var body: some View {
        
        switch state.status {
        case .initiate:
            Color.clear
                .frame(maxHeight: .infinity)
            
        case let .failure(_, oldLanding):
            if let oldLanding {
                factory.makeLandingView(oldLanding)
            } else {
                Color.clear
                    .frame(maxHeight: .infinity)
            }
            
        case let .loaded(landing):
            factory.makeLandingView(landing)
            
        case let .inflight(oldLanding):
            oldLanding.map {
                factory.makeLandingView($0)
            }
            if oldLanding == nil {
                factory.makeRefreshView()
                    .modifier(ViewByCenterModifier(height: config.spinnerHeight))
            }
        }
    }
}

public extension SavingsAccountContentView {
    
    typealias State = SavingsAccountContentState<Landing, InformerPayload>
    typealias Event = SavingsAccountContentEvent
    typealias Config = SavingsAccountContentConfig
    typealias Factory = SavingsAccountContentViewFactory<RefreshView, Landing, LandingView>
}

#Preview {
    SavingsAccountContentView.preview
}

extension SavingsAccountContentView
where RefreshView == Text,
      LandingView == Text,
      Landing == String,
      InformerPayload == String
{
    static let preview = SavingsAccountContentView(
        state: .init(status: .initiate, navTitle: .init(title: "", subtitle: "")),
        event: {_ in },
        config: .prod,
        factory: .init(
            makeRefreshView: { Text("Refresh") },
            makeLandingView: { Text($0) }
        ))
}

private struct ViewByCenterModifier: ViewModifier {
    
    let height: CGFloat
    
    func body(content: Content) -> some View {
        
        Group{
            content
                .frame(height: height)
        }
        .position(
            x: UIScreen.main.bounds.width/2,
            y: UIScreen.main.bounds.height/2 - height
        )
    }
}
