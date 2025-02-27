//
//  RootViewModelFactory+makeCreditCardMVP.swift
//  Vortex
//
//  Created by Igor Malyarov on 27.02.2025.
//

import Foundation

extension RootViewModelFactory {
    
    @inlinable
    func makeCreditCardMVP(
    ) -> CreditCardMVPDomain.Binder {
        
        return composeBinder(
            content: makeCreditCardMVPContent(),
            getNavigation: getNavigation,
            witnesses: .empty
        )
    }
    
    @inlinable
    func makeCreditCardMVPContent(
    ) -> CreditCardMVPDomain.Content {
        
        return .init(
            initialState: .init(otp: ""),
            reduce: { state, event in
                
                var state = state
                var effect: CreditCardMVPDomain.Effect?
                
                switch event {
                case let .otp(otp):
                    state.otp = otp
                }
                
                return (state, effect)
            },
            handleEffect: { effect, dispatch in
                
                switch effect { }
            },
            scheduler: schedulers.main
        )
    }
    
    @inlinable
    func getNavigation(
        select: CreditCardMVPDomain.Select,
        notify: @escaping CreditCardMVPDomain.Notify,
        completion: @escaping (CreditCardMVPDomain.Navigation) -> Void
    ) {
        // TODO: add call to update banners (on success?)
        schedulers.background.delay(for: .seconds(2)) {
            
            switch select {
            case let .order(payload):
                switch payload.otp {
                case "000000":
                    completion(.complete(.init(status: .completed)))
                    
                case "111111":
                    completion(.complete(.init(status: .rejected)))
                    
                default:
                    completion(.complete(.init(status: .inflight))) // TODO: replace with otp failure
                }
            }
        }
    }
}
