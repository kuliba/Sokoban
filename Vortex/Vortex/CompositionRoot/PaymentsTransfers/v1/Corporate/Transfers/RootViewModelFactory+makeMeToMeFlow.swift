//
//  RootViewModelFactory+makeMeToMeFlow.swift
//  Vortex
//
//  Created by Igor Malyarov on 30.01.2025.
//

import Foundation

extension RootViewModelFactory {
    
    @inlinable
    func makeMeToMeFlow() -> MeToMeDomain.Flow {
        
        // TODO: extract flow composer
        let binder: Binder<Void, MeToMeDomain.Flow> = composeBinder(
            content: (),
            delayProvider: delayProvider,
            getNavigation: getNavigation,
            witnesses: .empty
        )
        
        return binder.flow
    }
    
    @inlinable
    func delayProvider(
        navigation: MeToMeDomain.Navigation
    ) -> Delay {
        
        switch navigation {
        case .alert:         return .milliseconds(100)
        case .meToMe:        return .milliseconds(100)
        case .successMeToMe: return .milliseconds(100)
        }
    }
    
    @inlinable
    func getNavigation(
        select: MeToMeDomain.Select,
        notify: @escaping MeToMeDomain.Notify,
        completion: @escaping (MeToMeDomain.Navigation) -> Void
    ) {
        switch select {
        case let .alert(alert):
            completion(.alert(alert))
            
        case .meToMe:
            let node = makeMeToMeNode { notify($0.event) }
            completion(node.map { .meToMe($0) } ?? .alert("Ошибка создания платежа между своими."))
            
        case let .successMeToMe(successMeToMe):
            completion(.successMeToMe(successMeToMe))
        }
    }
}

// MARK: - Adapters

private extension RootViewModelFactory.MeToMeNotifyEvent {
    
    var event: MeToMeDomain.NotifyEvent {
        
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
