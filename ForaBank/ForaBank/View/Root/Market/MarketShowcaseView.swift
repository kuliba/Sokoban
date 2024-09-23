//
//  MarketShowcaseView.swift
//  ForaBank
//
//  Created by Andryusina Nataly on 19.09.2024.
//

import SwiftUI
import UIPrimitives
import LandingUIComponent
import Combine

struct MarketShowcaseView: View {
    
    let state: State
    let event: (Event) -> Void
    let factory: Factory
    let config: Config
    
    var body: some View {
        GeometryReader { geometry in
            
            content()
                .modifier(RefreshModifier(action: {
                    
                    if state != .inflight {
                        event(.update)
                    }
                }))
        }
    }
    
    
    @ViewBuilder
    private func content() -> some View {
        
        switch state {
        case .inflight:
            
            Group{
                SpinnerRefreshView(icon: .init("Logo Fora Bank"))
            }
            .position(
                x: UIScreen.main.bounds.width/2,
                y: UIScreen.main.bounds.height/2
            )
            
        default:
            VStack {
                Text("Market")
                Image.ic24MarketplaceActive
            }
        }
    }
}

extension MarketShowcaseView {
    
    typealias State = MarketShowcaseState
    typealias Event = MarketShowcaseEvent
    typealias Factory = ViewFactory
    typealias Config = UILanding.Component.Config
}

#Preview {
    MarketShowcaseView.preview
}

extension MarketShowcaseView {
    
    static let preview = MarketShowcaseView(
        state: .inflight,
        event: {_ in },
        factory: .preview,
        config: .default)
}

extension MarketShowcaseView {
    
    struct ViewFactory {
        
        let makeIconView: MakeIconView
    }
}

extension MarketShowcaseView.ViewFactory {
    
    typealias MakeIconView = (String) -> UIPrimitives.AsyncImage
    
    static let preview = MarketShowcaseView.ViewFactory.init(
        makeIconView: {_ in
                .init(
                    image: Image.cardPlaceholder,
                    publisher: Just(Image.ic24Tv).eraseToAnyPublisher()
                )})
}

private struct RefreshModifier: ViewModifier {
    
    let action: () -> Void
    let nameCoordinateSpace: String
    let offsetForStartUpdate: CGFloat
    
    init(
        action: @escaping () -> Void,
        nameCoordinateSpace: String = "scroll",
        offsetForStartUpdate: CGFloat = -100
    ) {
        self.action = action
        self.nameCoordinateSpace = nameCoordinateSpace
        self.offsetForStartUpdate = offsetForStartUpdate
    }
    
    func body(content: Content) -> some View {
        
        ScrollView(showsIndicators: false) {
            
            content
                .background(GeometryReader { geo in
                    
                    Color.clear
                        .preference(
                            key: ScrollOffsetKey.self,
                            value: -geo.frame(in: .named(nameCoordinateSpace)).origin.y)
                    
                })
                .onPreferenceChange(ScrollOffsetKey.self) {
                    
                    if $0 < offsetForStartUpdate {
                        action()
                    }
                }
        }
        .coordinateSpace(name: nameCoordinateSpace)
    }
    
    struct ScrollOffsetKey: PreferenceKey {
        
        typealias Value = CGFloat
        static var defaultValue: CGFloat { .zero }
        static func reduce(
            value: inout Value,
            nextValue: () -> Value
        ) {
            value += nextValue()
        }
    }
}
