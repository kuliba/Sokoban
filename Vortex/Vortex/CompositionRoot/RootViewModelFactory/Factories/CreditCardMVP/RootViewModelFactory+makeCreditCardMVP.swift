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
    func makeCreditCardMVPContent() -> CreditCardMVPDomain.Content {
        
        return ()
    }
    
    // TODO: remove on live implementation
    @inlinable
    func delayedGetNavigation(
        select: CreditCardMVPDomain.Select,
        notify: @escaping CreditCardMVPDomain.Notify,
        completion: @escaping (CreditCardMVPDomain.Navigation) -> Void
    ) {
        schedulers.background.delay(for: .seconds(1)) { [weak self] in
            
            self?.getNavigation(select: select, notify: notify, completion: completion)
        }
    }
    
    @inlinable
    func getNavigation(
        select: CreditCardMVPDomain.Select,
        notify: @escaping CreditCardMVPDomain.Notify,
        completion: @escaping (CreditCardMVPDomain.Navigation) -> Void
    ) {
        // TODO: add call to update banners (on success?)
        
        switch select {
        case let .alert(message):
            completion(.alert(message))
            
        case .failure:
            completion(.complete(.init(
                message: .failure,
                status: .failure
            )))
            
        case let .informer(message):
            schedulers.background.delay(for: .seconds(2)) { notify(.dismiss) }
            completion(.informer(message))
            
        case let .approved(consent, product):
            completion(.decision(.init(
                message: .approvedMessage,
                product: product,
                title: .approvedTitle,
                status: .approved(.init(
                    consent: consent,
                    info: .approvedInfo
                ))
            )))
            
        case .inReview:
            completion(.complete(.init(
                message: .inReview,
                status: .inReview
            )))
            
        case let .rejected(product):
            completion(.decision(.init(
                message: .rejectedMessage,
                product: product,
                title: .rejectedTitle,
                status: .rejected
            )))
        }
    }
}

private extension String {
    
    static let approvedInfo = "Про то что можно забрать в офисе"
    static let approvedMessage = "Ваша кредитная карта готова к оформлению!"
    static let approvedTitle = "Кредитная карта одобрена"
    
    static let failure = "Что-то пошло не так...\nПопробуйте позже."
    
    static let inReview = "Ожидайте рассмотрения Вашей заявки\nРезультат придет в Push/смс\nПримерное время рассмотрения заявки 10 минут."
    
    static let rejectedMessage = "К сожалению, ваша кредитная история не позволяет оформить карту"
    static let rejectedTitle = "Кредитная карта не одобрена"
}
