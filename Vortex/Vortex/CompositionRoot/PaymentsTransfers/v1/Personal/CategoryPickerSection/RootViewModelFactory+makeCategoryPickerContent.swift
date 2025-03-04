//
//  RootViewModelFactory+makeCategoryPickerContent.swift
//  Vortex
//
//  Created by Igor Malyarov on 15.01.2025.
//

import Combine
import PayHub
import PayHubUI

extension RootViewModelFactory {
    
    @inlinable
    func makeCategoryPickerContent(
        nanoServices: PaymentsTransfersPersonalNanoServices,
        map: @escaping ([ServiceCategory]) -> [Stateful<ServiceCategory, LoadState>] = { $0.pending }
    ) -> CategoryPickerContentDomain<ServiceCategory>.Content {
        
        let placeholderCount = settings.categoryPickerPlaceholderCount
        
        let makeID: () -> UUID = UUID.init
        let placeholderIDs = (0..<placeholderCount).map { _ in makeID() }
        let reducer = ItemListDomain.Reducer(
            makeID: makeID,
            makePlaceholders: { placeholderIDs }
        )
        
        let effectHandler = ItemListDomain.EffectHandler(
            load: { notify, completion in
                
                nanoServices.loadCategories {
                    
                    completion($0.map(map))
                }
            },
            reload: { notify, completion in
                
                nanoServices.reloadCategories(notify) {
                    
                    completion($0.map(map))
                }
            }
        )
        
        return .init(
            initialState: .init(
                prefix: [],
                suffix: (0..<placeholderCount).map { _ in .placeholder(.init()) }
            ),
            reduce: { reducer.reduce($0, $1) },
            handleEffect: { effectHandler.handleEffect($0, $1) },
            scheduler: schedulers.main
        )
    }
    
    @inlinable
    func emitting(
        content: CategoryPickerContentDomain<ServiceCategory>.Content
    ) -> some Publisher<FlowEvent<CategoryPickerSectionDomain.Select, Never>, Never> {
        
        // direct Flow call
        Empty()
    }
    
    @inlinable
    func dismissing(
        content: CategoryPickerContentDomain<ServiceCategory>.Content
    ) -> () -> Void {
        
        // direct Flow call
        return { }
    }
}

// MARK: - Helpers

extension Array where Element == ServiceCategory {
    
    var pending: [Stateful<Element, LoadState>] {
        
        map { .init(entity: $0, state: $0.paymentFlow == .standard ? .pending : .completed) }
    }
}

// MARK: - ItemListDomain

import Foundation
import PayHub
import RemoteServices
import ServiceCategoriesBackendV0

typealias ItemListDomain = PayHub.ItemListDomain<UUID, ServiceCategory>

extension ServiceCategory: Identifiable {
    
    public var id: CategoryType { type }
}

private extension String {
    
    static let standard = "STANDARD_FLOW"
}
