//
//  RootViewModelFactory+composeDecoratedServiceCategoryListLoaders.swift
//  Vortex
//
//  Created by Igor Malyarov on 21.10.2024.
//

import Foundation
import OperatorsListBackendV0
import PayHub
import RemoteServices
import SerialComponents
import VortexTools

typealias LoadState = VortexTools.LoadState

extension RootViewModelFactory {
    
    typealias ServiceCategoryLoad = (@escaping ([ServiceCategory]?) -> Void) -> Void
    typealias ServiceCategoryReload = (@escaping (ItemListEvent<ServiceCategory>) -> Void, @escaping ([ServiceCategory]?) -> Void) -> Void
    
    /// Compose `ServiceCategory` Loaders decorated with `operatorsService` (operators loading and caching).
    /// - Note:This method is responsible for threading.
    @inlinable
    func composeDecoratedServiceCategoryListLoaders(
    ) -> (load: ServiceCategoryLoad, reload: ServiceCategoryReload) {
        
        let remoteLoad = nanoServiceComposer.composeServiceCategoryRemoteLoad()
        
        let (loadCategories, reloadCategories) = composeLoaders(
            remoteLoad: remoteLoad,
            fromModel: { $0.serviceCategory },
            toModel: { $0.codable }
        )
        
        let decoratedReload = decoratedReload(reloadCategories)
        
        // threading
        let load = schedulers.userInitiated.scheduled(loadCategories)
        let reload = schedulers.userInitiated.scheduled(decoratedReload)
        
        return (load, reload)
    }
    
    /// - Warning: Threading is not the responsibility of this func.
    @inlinable
    func loadServicePaymentOperatorSerial(
        forCategory category: ServiceCategory
    ) -> String? {
        
        let storage = load(type: ServicePaymentOperatorStorage.self)
        
        return storage?.serial(for: category.type)
    }
    
    /// - Warning: Threading is not the responsibility of this func.
    @inlinable
    func load<T>(type: T.Type) -> T? where T: Decodable {
        
        model.localAgent.load(type: T.self)
    }
    
    /// - Warning: Threading is not the responsibility of this func.
    @inlinable
    func loadRemoteOperatorList(
        category: ServiceCategory,
        serial: String?,
        completion: @escaping (Result<SerialComponents.SerialStamped<String, [RemoteServices.ResponseMapper.ServicePaymentProvider]>, Error>) -> Void
    ) {
        let load = nanoServiceComposer.composeSerialResultLoad(
            createRequest: { serial in
                
                try Vortex.RequestFactory.getOperatorsListByParam(payload: .init(
                    serial: serial,
                    category: category
                ))
            },
            mapResponse: { data, response in
                
                let response = RemoteServices.ResponseMapper.mapGetOperatorsListByParamOperatorOnlyTrueResponse(data, response)
                
                return response.map { .init(value: $0.list, serial: $0.serial) }
            }
        )
        
        // keep scheduling for easier demo
        // schedulers.background.delay(for: .seconds(0)) {
        
        load(serial) { [load] in
            
            completion($0)
            _ = load
        }
        // }
    }
    
    /// Creates a decorated reload function for service categories that processes each category with state updates.
    ///
    /// This method wraps the provided `reloadCategories` closure with additional functionality for processing
    /// each category's state. The `notify` closure broadcasts state changes (`loading`, `completed`, or `failed`)
    /// for each category. Processing is non-blocking, with results passed to `onItemDataLoadComplete`.
    ///
    /// - Parameters:
    ///   - reloadCategories: A closure that reloads the list of service categories, delivering an optional array of categories.
    ///   - notify: A closure that receives state updates for each service category.
    /// - Returns: A `ServiceCategoryLoad` closure that reloads categories and asynchronously processes each category with state updates.
    /// - Warning: Threading is not the responsibility of this func.
    @inlinable
    func decoratedReload(
        _ reloadCategories: @escaping ServiceCategoryLoad
    ) -> ServiceCategoryReload {
        
        return { [/*weak */self] notify, completion in
            
            //guard let self else { return }
            
            let decorator = UpdatingLoadDecorator(
                decoratee: cachingLoadOperatorList,
                update: { category, loadState in
                    
                    notify(.update(state: loadState, forID: category.id))
                    debugLog(category: .network, message: "##### notify: \(String(describing: loadState)) \(category.type)")
                }
            )
            let batcher = Batcher { category, completion in
                
                decorator.load(category) { completion($0.failure) }
            }
            
            reloadCategories { [batcher] in
                
                completion($0)
                // non-blocking processing
                batcher.process(
                    // only categories with standard payment flow
                    ($0 ?? []).filter { $0.paymentFlow == .standard }
                ) { [weak self] in
                    
                    self?.onItemDataLoadComplete($0)
                    _ = batcher
                }
            }
        }
    }
    
    /// - Warning: Threading is not the responsibility of this func.
    @inlinable
    func cachingLoadOperatorList(
        category: ServiceCategory,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        let decorator = SerialStampedCachingDecorator(
            decoratee: loadRemoteOperatorList,
            cache: { [weak self] in
                
                self?.cacheOperatorList(for: category, data: $0, completion: $1)
            }
        )
        
        decorator.decorated(category) { [decorator] in
            
            completion($0.map { _ in () })
            _ = decorator
        }
    }
    
    /// - Warning: Threading is not the responsibility of this func.
    @inlinable
    func loadRemoteOperatorList(
        forCategory category: ServiceCategory,
        completion: @escaping (Result<SerialComponents.SerialStamped<String, [RemoteServices.ResponseMapper.ServicePaymentProvider]>, Error>) -> Void
    ) {
        let serial = loadServicePaymentOperatorSerial(forCategory: category)
        
        loadRemoteOperatorList(category: category, serial: serial, completion: completion)
    }
    
    /// - Warning: Threading is not the responsibility of this func.
    @inlinable
    func cacheOperatorList(
        for category: ServiceCategory,
        data: SerialComponents.SerialStamped<String, [RemoteServices.ResponseMapper.ServicePaymentProvider]>,
        completion: @escaping () -> Void
    ) {
        debugLog(category: .cache, message: "####### Loaded \(data.value.count) operators for \(category.type).")
        
        // mapping and expensive sorting
        let storage = ServicePaymentOperatorStorage(
            items: data.value.codables(),
            serial: data.serial
        )
        
        do {
            try model.localAgent.update(with: storage, serial: data.serial, using: ServicePaymentOperatorStorage.merge)
        } catch {
            errorLog(category: .cache, message: "Failed to cache ServicePaymentOperatorStorage with \(data.value.count) items.")
        }
        
        completion()
    }
    
    @inlinable
    func onItemDataLoadComplete(
        _ categories: [ServiceCategory]
    ) {
        if !categories.isEmpty {
            
            errorLog(category: .network, message: "##### onItemDataLoadComplete: failed to load operators for \(categories.count) categories: " + String(describing: categories.map(\.type)))
        }
    }
}

// MARK: - ServicePaymentOperator Storage

typealias ServicePaymentOperatorStorage = VortexTools.CategorizedStorage<ServiceCategory.CategoryType, CodableServicePaymentOperator>

extension CodableServicePaymentOperator: Categorized {
    
    var category: ServiceCategory.CategoryType { type }
}

struct CodableServicePaymentOperator: Codable, Equatable, Identifiable {
    
    let id: String
    let inn: String
    let md5Hash: String?
    let name: String
    let type: String
    let sortedOrder: Int
}

extension Array where Element == RemoteServices.ResponseMapper.ServicePaymentProvider {
    
    /// - Warning: performs expensive sorting.
    func codables() -> [CodableServicePaymentOperator] {
        
        return .init(providers: self)
    }
}

extension Array where Element == CodableServicePaymentOperator {
    
    /// - Warning: performs expensive sorting.
    init(
        providers: [RemoteServices.ResponseMapper.ServicePaymentProvider]
    ) {
        self.init(
            providers: providers,
            priority: { $0.characterSortPriority() }
        )
    }
    
    /// - Warning: performs expensive sorting.
    init(
        providers: [RemoteServices.ResponseMapper.ServicePaymentProvider],
        priority: (Character) -> Int
    ) {
        let decorated = providers.map {
            
            (provider: $0,
             nameSortKey: $0.nameSortKey(priority: priority),
             innSortKey: $0.innSortKey(priority: priority))
        }
        
        let sorted = decorated.sorted {
            
            if $0.nameSortKey != $1.nameSortKey {
                return $0.nameSortKey < $1.nameSortKey
            } else {
                return $0.innSortKey < $1.innSortKey
            }
        }
        
        self = sorted
            .map(\.provider)
            .enumerated()
            .map(CodableServicePaymentOperator.init)
    }
}

extension RemoteServices.ResponseMapper.ServicePaymentProvider {
    
    @inlinable
    func nameSortKey(priority: (Character) -> Int) -> SortKey {
        
        return .init(string: name, priority: priority)
    }
    
    @inlinable
    func innSortKey(priority: (Character) -> Int) -> SortKey {
        
        return .init(string: inn, priority: priority)
    }
}

private extension CodableServicePaymentOperator {
    
    init(
        _ sortedOrder: Int,
        _ provider: RemoteServices.ResponseMapper.ServicePaymentProvider
    ) {
        self.init(
            id: provider.id,
            inn: provider.inn,
            md5Hash: provider.md5Hash,
            name: provider.name,
            type: provider.type,
            sortedOrder: sortedOrder
        )
    }
}
