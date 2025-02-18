//
//  SavingsAccountContentView.swift
//
//
//  Created by Andryusina Nataly on 03.12.2024.
//

import SwiftUI

public struct SavingsAccountContentView<RefreshView, LandingView, Landing, InformerPayload, InformerView>: View
where RefreshView: View,
      LandingView: View,
      InformerView: View
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
            
        case let .failure(failure, oldLanding):
            ZStack(alignment: .top) {
                
                if let oldLanding {
                    factory.makeLandingView(oldLanding)
                } else {
                    Color.clear
                        .frame(maxHeight: .infinity)
                }
                
                if case let .informer(informer) = failure {
                    factory.makeInformerView(informer)
                }
            }
            
        case let .loaded(landing):
            factory.makeLandingView(landing)
            
        case let .inflight(oldLanding):
            oldLanding.map {
                factory.makeLandingView($0)
            }
            if oldLanding == nil {
                factory.refreshView
                    .modifier(ViewByCenterModifier(height: config.spinnerHeight))
            }
        }
    }
}

public extension SavingsAccountContentView {
    
    typealias State = SavingsAccountContentState<Landing, InformerPayload>
    typealias Event = SavingsAccountContentEvent
    typealias Config = SavingsAccountContentConfig
    typealias Factory = SavingsAccountContentViewFactory<RefreshView, Landing, LandingView, InformerPayload, InformerView>
}

#Preview {
    SavingsAccountContentView.preview
}

extension SavingsAccountContentView
where RefreshView == Text,
      LandingView == Text,
      Landing == String,
      InformerPayload == String,
      InformerView == Text
{
    static let preview = SavingsAccountContentView(
        state: .init(status: .initiate, navTitle: .init(title: "", subtitle: "")),
        event: {_ in },
        config: .prod,
        factory: .init(
            refreshView: Text("Refresh"), 
            makeInformerView: { Text($0) },
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
