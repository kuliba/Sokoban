//
//  RootViewModelFactory+makeCreditCardMVP.swift
//  Vortex
//
//  Created by Igor Malyarov on 27.02.2025.
//

import Foundation

extension RootViewModelFactory {
    
    @inlinable
    func makeCreditCardMVP() -> CreditCardMVPDomain.Binder {
        
        // TODO: remove on live implementation
        let isLive = false
        
        return composeBinder(
            content: makeCreditCardMVPContent(),
            getNavigation: isLive ? getNavigation : delayedGetNavigation,
            witnesses: .empty
        )
    }
    
    @inlinable
    func makeCreditCardMVPContent() -> Void {
        
        return ()
    }
    
    // TODO: remove on live implementation
    @inlinable
    func delayedGetNavigation(
        select: CreditCardMVPFlowDomain.Select,
        notify: @escaping CreditCardMVPFlowDomain.Notify,
        completion: @escaping (CreditCardMVPFlowDomain.Navigation) -> Void
    ) {
        schedulers.background.delay(for: .seconds(1)) { [weak self] in
            
            self?.getNavigation(select: select, notify: notify, completion: completion)
        }
    }
    
    @inlinable
    func getNavigation(
        select: CreditCardMVPFlowDomain.Select,
        notify: @escaping CreditCardMVPFlowDomain.Notify,
        completion: @escaping (CreditCardMVPFlowDomain.Navigation) -> Void
    ) {
        // TODO: add call to update banners (on success?)
        
        // TODO: add tests for notify
        if case .informer = select {
            
            schedulers.background.delay(for: .seconds(2)) { notify(.dismiss) }
        }
        
        completion(select.navigation)
    }
}

// MARK: - Helpers

private extension String {
    
    static let approvedInfo = "Про то что можно забрать в офисе"
    static let approvedMessage = "Ваша кредитная карта готова к оформлению!"
    static let approvedTitle = "Кредитная карта одобрена"
    
    static let failure = "Что-то пошло не так...\nПопробуйте позже."
    
    static let inReview = "Ожидайте рассмотрения Вашей заявки\nРезультат придет в Push/смс\nПримерное время рассмотрения заявки 10 минут."
    
    static let rejectedMessage = "К сожалению, ваша кредитная история не позволяет оформить карту"
    static let rejectedTitle = "Кредитная карта не одобрена"
}

// MARK: - Adapters

private extension CreditCardMVPFlowDomain.Select {
    
    var navigation: CreditCardMVPFlowDomain.Navigation {
        
        switch self {
        case let .alert(message):
            return .alert(message)
            
        case let .approved(consent, product):
            return .decision(.init(
                message: .approvedMessage,
                status: .approved(.init(
                    consent: consent,
                    info: .approvedInfo,
                    product: product
                )),
                title: .approvedTitle
            ))
            
        case .failure:
            return .complete(.init(
                message: .failure,
                status: .failure
            ))
            
        case let .informer(message):
            return .informer(message)
            
        case .inReview:
            return .complete(.init(
                message: .inReview,
                status: .inReview
            ))
            
        case .rejected:
            return .decision(.init(
                message: .rejectedMessage,
                status: .rejected,
                title: .rejectedTitle
            ))
        }
    }
}
