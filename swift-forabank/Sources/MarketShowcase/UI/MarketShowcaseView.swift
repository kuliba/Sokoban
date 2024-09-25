//
//  MarketShowcaseView.swift
//  ForaBank
//
//  Created by Andryusina Nataly on 24.09.2024.
//

import SwiftUI
import UIPrimitives

public struct MarketShowcaseView<RefreshView, Landing>: View
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
            /*.alert(
                item: state.alert,
                content: errorAlert(event: event)
            )*/
    }
    
    @ViewBuilder
    private func content() -> some View {
        
        switch state.status {
        case .inflight:
            
            factory.makeRefreshView()
                .modifier(ViewByCenterModifier(height: config.spinnerHeight))
            Button(action: { event(.loadFailure) }, label: { Text("Informer")})
            
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
    
    func errorAlert(
        event: @escaping (Event<Landing>) -> Void
    ) -> (FailureAlert) -> Alert {
        
        return { alert in

            return .init(
                with: .init(
                    title: "Ошибка!",
                    message: alert.message,
                    primaryButton: .init(
                        type: .default,
                        title: "OK",
                        event: .load
                    )
                ),
                event: event
            )
        }
    }
}

public extension MarketShowcaseView {
    
    typealias State = MarketShowcaseContentState<Landing>
    typealias Event = MarketShowcaseContentEvent
    typealias Config = MarketShowcaseConfig
    typealias Factory = ViewFactory<RefreshView>
}

#Preview {
    MarketShowcaseView.preview
}

extension MarketShowcaseView where RefreshView == Text, Landing == String {
    
    static let preview = MarketShowcaseView(
        state: .init(status: .inflight),
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
