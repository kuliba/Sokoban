//
//  MarketShowcaseFlowView.swift
//
//
//  Created by Andryusina Nataly on 25.09.2024.
//

import SwiftUI
import UIPrimitives

public struct MarketShowcaseFlowView<ContentView, Destination, InformerPayload>: View
where ContentView: View {
    
    private let state: State
    private let event: (Event) -> Void
    private let contentView: () -> ContentView
    
    public init(
        state: State,
        event: @escaping (Event) -> Void,
        contentView: @escaping () -> ContentView
    ) {
        self.state = state
        self.event = event
        self.contentView = contentView
    }
    
    public var body: some View {
        
        contentView()
            .alert(
                item: backendFailure,
                content: alert(event: event)
            )
    }
    
    func alert(
        event: @escaping (Event) -> Void
    ) -> (AlertFailure) -> Alert {
        
        return { alert in

            return .init(
                with: .init(
                    title: "Ошибка!",
                    message: alert.message,
                    primaryButton: .init(
                        type: .default,
                        title: "OK",
                        event: .select(.goToMain)
                    )
                ),
                event: event
            )
        }
    }
}

extension MarketShowcaseFlowView {
    
    var backendFailure: AlertFailure? {
        
        guard case let .alert(alertFailure) = state.status
        else { return nil }
        
        return alertFailure
    }

    var destination: Destination? {
        
        guard case let .destination(destination) = state.status
        else { return nil }
        
        return destination
    }
}

public extension MarketShowcaseFlowView {
    
    typealias State = MarketShowcaseFlowState<Destination, InformerPayload>
    typealias Event = MarketShowcaseFlowEvent<Destination, InformerPayload>
}
