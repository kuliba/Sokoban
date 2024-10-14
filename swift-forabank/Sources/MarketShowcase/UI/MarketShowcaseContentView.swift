//
//  MarketShowcaseContentView.swift
//  ForaBank
//
//  Created by Andryusina Nataly on 25.09.2024.
//

import SwiftUI
import UIPrimitives

public struct MarketShowcaseContentView<RefreshView, LandingView, Landing, InformerPayload>: View
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
        
        content()
            .refresh(action: {
                event(.load)
            })
    }
    
    @ViewBuilder
    private func content() -> some View {
       
        ZStack {
            
            switch state.status {
            case .initiate, .failure:
                Color.clear
                    .frame(maxHeight: .infinity)
                
            case let .loaded(landing):
                factory.makeLandingView(landing)
                
            case .inflight:
                factory.makeRefreshView()
                    .modifier(ViewByCenterModifier(height: config.spinnerHeight))
            }
        }
    }
}

public extension MarketShowcaseContentView {
    
    typealias State = MarketShowcaseContentState<Landing, InformerPayload>
    typealias Event = MarketShowcaseContentEvent
    typealias Config = MarketShowcaseConfig
    typealias Factory = ViewFactory<RefreshView, Landing, LandingView>
}

#Preview {
    MarketShowcaseContentView.preview
}

extension MarketShowcaseContentView
where RefreshView == Text,
      LandingView == Text,
      Landing == String,
      InformerPayload == String
{
    
    static let preview = MarketShowcaseContentView(
        state: .init(status: .initiate),
        event: {_ in },
        config: .iFora,
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
