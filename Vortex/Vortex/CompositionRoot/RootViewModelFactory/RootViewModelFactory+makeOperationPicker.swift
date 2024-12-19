//
//  RootViewModelFactory+makeOperationPicker.swift
//  Vortex
//
//  Created by Igor Malyarov on 21.10.2024.
//

import Combine
import VortexTools
import Foundation
import PayHub
import PayHubUI

private typealias Domain = OperationPickerDomain

protocol ReloadableOperationPicker: OperationPicker {
    
    func reload()
}

extension OperationPickerDomain.Binder: ReloadableOperationPicker {
    
    func reload() {
        
        content.event(.reload)
    }
}

extension RootViewModelFactory {
    
    typealias LoadLatestCompletion = ([Latest]?) -> Void
    typealias LoadLatest = (@escaping LoadLatestCompletion) -> Void
    
    @inlinable
    func makeOperationPicker(
        loadLatest: @escaping LoadLatest,
        prefix: [LoadablePickerState<UUID, OperationPickerDomain.Select>.Item]
    ) -> ReloadableOperationPicker {
        
        let fetchingUpdater = makeLatestUpdater(fetch: loadLatest)
        
        return makeOperationPicker(load: fetchingUpdater.load, prefix: prefix)
    }
    
    @inlinable
    func makeOperationPicker(
        load: @escaping (@escaping ([OperationPickerDomain.Select]?) -> Void) -> Void,
        prefix: [LoadablePickerState<UUID, OperationPickerDomain.Select>.Item]
    ) -> ReloadableOperationPicker {
        
        let content = composeLoadablePickerModel(
            load: load,
            prefix: prefix,
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
                completion(.exchangeFailure)
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
    
    @inlinable
    func makeLatestUpdater(
        fetch: @escaping (@escaping ([Latest]?) -> Void) -> Void
    ) -> ReactiveFetchingUpdater<(), [Latest], [OperationPickerDomain.Select]> {
        
        ReactiveFetchingUpdater(
            fetcher: AnyOptionalFetcher(fetch: fetch),
            updater: AnyReactiveUpdater {
                
            // TODO: reuse/extract mapping from LatestPaymentsView.ViewModel.bind() - see LatestPaymentsViewComponent.swift:41
                Just($0.map { .latest($0) })
                    .handleEvents(receiveOutput: { print("===== latest", $0.count) })
                    .eraseToAnyPublisher()
            }
        )
    }
}
