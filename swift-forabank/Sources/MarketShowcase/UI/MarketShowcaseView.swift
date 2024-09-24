//
//  MarketShowcaseView.swift
//  ForaBank
//
//  Created by Andryusina Nataly on 24.09.2024.
//

import SwiftUI
import UIPrimitives

public struct MarketShowcaseView<RefreshView>: View
where RefreshView: View
{
    
    let state: State
    let event: (Event) -> Void
    let config: Config
    let factory: Factory
    
    public init(
        state: State,
        event: @escaping (Event) -> Void,
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
                if state != .inflight {
                    event(.update)
                }
            })
    }
    
    @ViewBuilder
    private func content() -> some View {
        
        switch state {
        case .inflight:
            
            factory.makeRefreshView()
                .modifier(ViewByCenterModifier(height: config.spinnerHeight))
            Button(action: { event(.loaded) }, label: { Text("Loaded")})
            Button(action: { event(.failure(.timeout)) }, label: { Text("Informer")})
            Button(action: { event(.failure(.error)) }, label: { Text("Alert")})

        case .loaded:
            VStack {
                Text("Market")
            }
            .frame(maxHeight: .infinity)
            .padding()

        case .failure:
            VStack {
                Text("Failure")
            }
            .frame(maxHeight: .infinity)
            .padding()
        }
    }
}

public extension MarketShowcaseView {
    
    typealias State = MarketShowcaseState
    typealias Event = MarketShowcaseEvent
    typealias Config = MarketShowcaseConfig
    typealias Factory = ViewFactory<RefreshView>
}

#Preview {
    MarketShowcaseView.preview
}

extension MarketShowcaseView where RefreshView == Text {
    
    static let preview = MarketShowcaseView(
        state: .inflight,
        event: {_ in },
        config: .iFora, 
        factory: .init(makeRefreshView: { Text("Refresh") }))
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
