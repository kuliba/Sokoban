//
//  MarketShowcaseContentView.swift
//  ForaBank
//
//  Created by Andryusina Nataly on 25.09.2024.
//

import SwiftUI
import UIPrimitives

public struct MarketShowcaseContentView<RefreshView, Landing>: View
where RefreshView: View
{
    
    let state: State
    let event: (Event<Landing>) -> Void
    let config: Config
    let factory: Factory
    
    public init(
        state: State,
        event: @escaping (Event<Landing>) -> Void,
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
        
        switch state.status {
        case .initiate:
            Text("Initiate")
                .frame(maxHeight: .infinity)
                .padding()
            
        case .inflight:
            
            factory.makeRefreshView()
                .modifier(ViewByCenterModifier(height: config.spinnerHeight))
            
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

public extension MarketShowcaseContentView {
    
    typealias State = MarketShowcaseContentState<Landing>
    typealias Event = MarketShowcaseContentEvent
    typealias Config = MarketShowcaseConfig
    typealias Factory = ViewFactory<RefreshView>
}

#Preview {
    MarketShowcaseContentView.preview
}

extension MarketShowcaseContentView where RefreshView == Text, Landing == String {
    
    static let preview = MarketShowcaseContentView(
        state: .init(status: .initiate),
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

#warning("move to module")
extension View {
    
    func alert<Item: Identifiable>(
        item: Item?,
        content: (Item) -> Alert
    ) -> some View {
        
        alert(
            item: .init(
                get: { item },
                set: { _ in } // managed by action in content
            ),
            content: content
        )
    }
}
