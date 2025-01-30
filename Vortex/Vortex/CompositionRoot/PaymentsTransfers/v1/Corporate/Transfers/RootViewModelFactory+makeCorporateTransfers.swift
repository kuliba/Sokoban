//
//  RootViewModelFactory+makeCorporateTransfers.swift
//  Vortex
//
//  Created by Igor Malyarov on 30.01.2025.
//

import Foundation

extension RootViewModelFactory {
    
    @inlinable
    func makeCorporateTransfers(
    ) -> PaymentsTransfersCorporateTransfersDomain.Binder {
        
        composeBinder(
            content: (),
            delayProvider: delayProvider,
            getNavigation: getNavigation,
            witnesses: .empty
        )
    }
    
    @inlinable
    func delayProvider(
        navigation: PaymentsTransfersCorporateTransfersDomain.Navigation
    ) -> Delay {
        
        switch navigation {
        case .alert:         return .milliseconds(100)
        case .meToMe:        return .milliseconds(100)
        case .openProduct:   return .milliseconds(100)
        case .successMeToMe: return .milliseconds(100)
        }
    }
    
    @inlinable
    func getNavigation(
        select: PaymentsTransfersCorporateTransfersDomain.Select,
        notify: @escaping PaymentsTransfersCorporateTransfersDomain.Notify,
        completion: @escaping (PaymentsTransfersCorporateTransfersDomain.Navigation) -> Void
    ) {
        switch select {
        case let .alert(alert):
            completion(.alert(alert))
            
        case .meToMe:
            let node = makeMeToMeNode { notify($0.event) }
            completion(node.map { .meToMe($0) } ?? .alert("Ошибка создания платежа между своими."))
            
        case .openProduct:
            completion(.openProduct(""))
            
        case let .successMeToMe(successMeToMe):
            completion(.successMeToMe(successMeToMe))
        }
    }
}

// MARK: - Adapters

private extension RootViewModelFactory.MeToMeNotifyEvent {
    
    var event: PaymentsTransfersCorporateTransfersDomain.NotifyEvent {
        
        switch self {
        case .dismiss:
            return .dismiss
            
        case let .isLoading(isLoading):
            return .isLoading(isLoading)
            
        case let .select(select):
            switch select {
            case let .alert(alert):
                return .select(.alert(alert))
                
            case let .successMeToMe(successMeToMe):
                return .select(.successMeToMe(successMeToMe))
            }
        }
    }
}
