//
//  RootViewModelFactory+makeOperationPicker.swift
//  Vortex
//
//  Created by Igor Malyarov on 21.10.2024.
//

import Combine
import Foundation
import PayHub
import PayHubUI
import SwiftUI
import VortexTools

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
                
        return composeBinder(
            content: content,
            delayProvider: delayProvider,
            getNavigation: getNavigation,
            witnesses: .init(emitting: emitting, dismissing: dismissing)
        )
    }
    
    private func delayProvider(
        navigation: Domain.Navigation
    ) -> Delay {
        
        switch navigation {
        case .exchange:        return settings.delay
        case .exchangeFailure: return settings.delay
        case .latest:          return settings.delay
        case .outside:         return .milliseconds(100)
        case .templates:       return settings.delay
        }
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
            completion(exchange.map { .exchange($0) } ?? .exchangeFailure)
            
        case let .latest(latest):
            processPayments(
                lastPayment: .init(latest),
                notify: { notify($0.event) },
                completion: { $0.map { completion(.latest($0)) }}
            )
            
        case .templates:
            completion(.templates)
        }
    }
    
    @inlinable
    func emitting(
        content: OperationPickerDomain.Content
    ) -> some Publisher<FlowEvent<OperationPickerDomain.Select, Never>, Never> {
        
        content.$state.compactMap(\.selected).map(FlowEvent.select)
    }
    
    @inlinable
    func dismissing(
        content: OperationPickerDomain.Content
    ) -> () -> Void {
        
        return { content.event(.select(nil)) }
    }
    
    typealias OperationPickerUpdater = ReactiveFetchingUpdater<(), [Latest], [OperationPickerDomain.Select]>
    
    @inlinable
    func makeLatestUpdater(
        fetch: @escaping (@escaping ([Latest]?) -> Void) -> Void
    ) -> OperationPickerUpdater {
        
        return .init(
            fetcher: AnyOptionalFetcher(fetch: fetch),
            updater: AnyReactiveUpdater { [weak self] latest in
                
                guard let self else {
                    return Just([]).eraseToAnyPublisher()
                }
                
                let md5Hashes = latest.compactMap(\.md5Hash)
                let dictionaryPublisher = infra.imageCache.imagesDictionaryPublisher(for: md5Hashes)
                
                return latest
                    .updating(with: dictionaryPublisher)
                    .handleEvents(receiveOutput: {
                        
                        print("####### updating: ", String(describing: $0.map {
                            
                            ($0.md5Hash, $0.avatarImage)
                        }))
                    })
                    .map { $0.map(OperationPickerDomain.Select.latest) }
                    .eraseToAnyPublisher()
            }
        )
    }
}

// MARK: - Adapters

private extension AnywayFlowState.Status.Outside {
    
    var event: Domain.FlowDomain.NotifyEvent {
        
        switch self {
        case .main:     return .dismiss
        case .payments: return .dismiss
        }
    }
}

extension Latest: KeyProviding, ValueUpdatable {
        
    // Use `md5Hash` as the unique key
    public var key: String { md5Hash ?? "" }
    
    // Return a new `Latest` with its `image` field updated
    public func updated(value: Image) -> Self {
        
        updating(with: value)
    }
}
