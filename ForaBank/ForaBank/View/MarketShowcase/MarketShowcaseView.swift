//
//  MarketShowcaseView.swift
//  ForaBank
//
//  Created by Andryusina Nataly on 19.09.2024.
//

import SwiftUI
import UIPrimitives

struct MarketShowcaseView: View {
    
    let state: State
    let event: (Event) -> Void
    let config: Config
    
    var body: some View {
        
        content()
            .modifier(RefreshModifier(action: {
                if state != .inflight {
                    event(.update)
                }
            }))
    }
    
    @ViewBuilder
    private func content() -> some View {
        
        switch state {
        case .inflight:
            
            SpinnerRefreshView(icon: .init("Logo Fora Bank"))
                .modifier(ViewByCenterModifier(height: config.spinnerHeight))
            Button(action: { event(.loaded) }, label: { Text("Loaded")})
        default:
            VStack {
                Text("Market")
                Image.ic24MarketplaceActive
            }
            .frame(maxHeight: .infinity)
            .padding()
        }
    }
}

extension MarketShowcaseView {
    
    typealias State = MarketShowcaseState
    typealias Event = MarketShowcaseEvent
    typealias Config = MarketShowcaseConfig
}

#Preview {
    MarketShowcaseView.preview
}

extension MarketShowcaseView {
    
    static let preview = MarketShowcaseView(
        state: .inflight,
        event: {_ in },
        config: .iFora)
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
