//
//  makePaymentsTransfersPersonalToolbar.swift
//  ForaBank
//
//  Created by Igor Malyarov on 22.11.2024.
//

import Foundation
import PayHub

extension RootViewModelFactory {
    
    func makePaymentsTransfersPersonalToolbar(
        selection: PaymentsTransfersPersonalToolbarState.Selection? = nil
    ) -> PaymentsTransfersPersonalToolbarDomain.Binder {
        
        return compose(
            getNavigation: { select, notify, completion in
                
                switch select {
                case .profile:
                    completion(.profile(.init()))
                    
                case .qr:
                    completion(.qr(.init()))
                }
            },
            content: makeToolbarContent(selection: selection),
            witnesses: .init(
                emitting: {
                    
                    $0.$state.compactMap {
                        
                        switch $0.selection {
                        case .none:    return .none
                        case .profile: return .profile
                        case .qr:      return .qr
                        }
                    }
                    .eraseToAnyPublisher()
                },
                receiving: { content in { content.event(.select(nil)) }}
            )
        )
    }
    
    private func makeToolbarContent(
        selection: PaymentsTransfersPersonalToolbarState.Selection?
    ) -> PaymentsTransfersPersonalToolbarDomain.Content {
        
        let reducer = PaymentsTransfersPersonalToolbarReducer()
        let effectHandler = PaymentsTransfersPersonalToolbarEffectHandler()
        
        return .init(
            initialState: .init(selection: selection),
            reduce: reducer.reduce(_:_:),
            handleEffect: effectHandler.handleEffect(_:_:),
            scheduler: schedulers.main
        )
    }
}
