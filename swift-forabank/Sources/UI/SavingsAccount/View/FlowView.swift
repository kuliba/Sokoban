//
//  FlowView.swift
//  
//
//  Created by Andryusina Nataly on 04.12.2024.
//

import SwiftUI
import UIPrimitives

public struct FlowView<ContentView, InformerPayload>: View
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
                    title: "Ошибка",
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

extension FlowView {
    
    var backendFailure: AlertFailure? {
        
        guard case let .alert(alertFailure) = state.status
        else { return nil }
        
        return alertFailure
    }
}

public extension FlowView {
    
    typealias State = FlowState<InformerPayload>
    typealias Event = FlowEvent<InformerPayload>
}
