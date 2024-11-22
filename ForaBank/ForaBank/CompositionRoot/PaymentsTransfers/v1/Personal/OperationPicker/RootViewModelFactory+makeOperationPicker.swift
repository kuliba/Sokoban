//
//  RootViewModelFactory+makeOperationPicker.swift
//  ForaBank
//
//  Created by Igor Malyarov on 21.10.2024.
//

import Foundation
import PayHubUI

private typealias Domain = OperationPickerDomain

extension RootViewModelFactory {
    
    func makeOperationPicker(
        nanoServices: PaymentsTransfersPersonalNanoServices
    ) -> OperationPickerDomain.Binder {
        
        let operationPickerContent = makeOperationPickerContent(
            load: { completion in
                
                nanoServices.loadAllLatest {
                    
                    completion(((try? $0.get()) ?? []).map { .latest($0) })
                }
            }
        )
        
        return compose(
            getNavigation: getNavigation,
            content: operationPickerContent,
            witnesses: .init(
                emitting: {
                    
                    $0.$state
                        .compactMap(\.selected)
                        .eraseToAnyPublisher()
                },
                receiving: { content in { content.event(.select(nil)) }}
            )
        )
    }
    
    private func makeOperationPickerContent(
        load: @escaping Load<[Domain.Select]>
    ) -> Domain.Content {
        
        let operationPickerContentComposer = LoadablePickerModelComposer<UUID, Domain.Select>(
            load: load,
            scheduler: schedulers.main
        )
        let operationPickerPlaceholderCount = settings.operationPickerPlaceholderCount
        
        return operationPickerContentComposer.compose(
            prefix: [
                .element(.init(.templates)),
                .element(.init(.exchange))
            ],
            suffix: [],
            placeholderCount: operationPickerPlaceholderCount
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
            completion(.templates(.init()))
        }
    }
}
