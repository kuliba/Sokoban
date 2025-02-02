//
//  FlowView.swift
//
//
//  Created by Andryusina Nataly on 04.12.2024.
//

import SwiftUI
import UIPrimitives
import SavingsAccount

extension SavingsAccountDomain {
    
    struct FlowView<ContentView, InformerView>: View
    where ContentView: View,
          InformerView: View {
        
        let state: State
        let event: (Event) -> Void
        let contentView: () -> ContentView
        let informerView: (Informer) -> InformerView
        
        var body: some View {
            
            ZStack {
                
                state.navigation?.informer.map(informerView)
                    .zIndex(1)
                
                contentView()
                    .alert(
                        item: backendFailure,
                        content: alert(event: event)
                    )
            }
        }
    }
}

extension SavingsAccountDomain.Navigation {
    
    var informer: SavingsAccountDomain.InformerPayload? {
        
        guard case let .failure(.timeout(informer)) = self
        else { return nil }
        
        return informer
    }
    
    var alertMessage: String? {
        
        guard case let .failure(.error(message)) = self
        else { return nil }
        
        return message
    }
}

private extension SavingsAccountDomain.FlowView {
    
    var backendFailure: AlertFailure? {
        
        guard let message = state.navigation?.alertMessage
        else { return nil }
        
        return .init(message: message)
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

extension SavingsAccountDomain.FlowView {
    
    typealias State = SavingsAccountDomain.FlowDomain.State
    typealias Event = SavingsAccountDomain.FlowDomain.Event
    typealias Informer = SavingsAccountDomain.InformerPayload
}
