//
//  RootViewModelFactory+makeOperationPicker.swift
//  ForaBank
//
//  Created by Igor Malyarov on 21.10.2024.
//

import Foundation
import PayHubUI

private typealias Domain = OperationPickerDomain

private extension PaymentsTransfersPersonalNanoServices {
    
    func load(
        completion: @escaping ([OperationPickerDomain.Select]?) -> Void
    ) {
        loadAllLatest {
            
            completion(((try? $0.get()) ?? []).map { .latest($0) })
        }
    }
}

extension RootViewModelFactory {
    
    @inlinable
    func makeOperationPicker(
        _ nanoServices: PaymentsTransfersPersonalNanoServices
    ) -> OperationPickerDomain.Binder {
        
        let content = composeLoadablePickerModel(
            load: nanoServices.load(completion:),
            prefix: [
                .element(.init(.templates)),
                .element(.init(.exchange))
            ],
            suffix: [],
            placeholderCount: settings.operationPickerPlaceholderCount
        )
        
        return compose(
            getNavigation: getNavigation,
            content: content,
            witnesses: witnesses()
        )
    }
    
    private func getNavigation(
        select: Domain.Select,
        notify: @escaping Domain.Notify,
        completion: @escaping (Domain.Navigation) -> Void
    ) {
        switch select {
        case .exchange:
            let composer = CurrencyWalletViewModelComposer(model: model)
            let exchange = composer.compose(dismiss: { notify(.dismiss) })
            
            if let exchange {
                completion(.exchange(exchange))
            } else {
                completion(.status(.exchangeFailure))
            }
            
        case let .latest(latest):
            completion(.latest(.init(latest: latest)))
            
        case .templates:
            completion(.templates)
        }
    }
    
    private func witnesses() -> Domain.Composer.Witnesses {
        
        return .init(
            emitting: { $0.$state.compactMap(\.selected) },
            dismissing: { content in { content.event(.select(nil)) }}
        )
    }
}
