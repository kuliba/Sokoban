//
//  RootViewModelFactory+composeLoadablePickerModel.swift
//  Vortex
//
//  Created by Igor Malyarov on 22.11.2024.
//

import Foundation
import PayHub
import PayHubUI

extension RootViewModelFactory {
    
    /// Composes a `LoadablePickerModel` with a custom identifier type, load and reload functions, and item decorations.
    ///
    /// - Parameters:
    ///   - load: The closure to load items asynchronously.
    ///   - reload: The closure to reload items asynchronously.
    ///   - makeID: The closure to create a unique identifier.
    ///   - prefix: Static items to prepend before loaded items.
    ///   - suffix: Static items to append after loaded items.
    ///   - placeholderCount: The number of placeholder items to show during loading.
    /// - Returns: A `LoadablePickerModel` configured with the provided parameters.
    func composeLoadablePickerModel<ID, Item>(
        load: @escaping (@escaping ([Item]?) -> Void) -> Void,
        reload: @escaping (@escaping ([Item]?) -> Void) -> Void,
        makeID: @escaping () -> ID,
        prefix: [LoadablePickerState<ID, Item>.Item] = [],
        suffix: [LoadablePickerState<ID, Item>.Item],
        placeholderCount: Int
    ) -> LoadablePickerModel<ID, Item> {
        
        let composer = LoadablePickerModelComposer<ID, Item>(
            load: load,
            reload: reload,
            makeID: makeID,
            scheduler: schedulers.main
        )
        
        return composer.compose(
            prefix: prefix,
            suffix: suffix,
            placeholderCount: placeholderCount
        )
    }
    
    /// Composes a `LoadablePickerModel` with a custom identifier type and identical load/reload behavior.
    ///
    /// - Parameters:
    ///   - load: The closure to load or reload items asynchronously.
    ///   - makeID: The closure to create a unique identifier.
    ///   - prefix: Static items to prepend before loaded items.
    ///   - suffix: Static items to append after loaded items.
    ///   - placeholderCount: The number of placeholder items to show during loading.
    /// - Returns: A `LoadablePickerModel` configured with the provided parameters.
    func composeLoadablePickerModel<ID, Item>(
        load: @escaping (@escaping ([Item]?) -> Void) -> Void,
        makeID: @escaping () -> ID,
        prefix: [LoadablePickerState<ID, Item>.Item] = [],
        suffix: [LoadablePickerState<ID, Item>.Item],
        placeholderCount: Int
    ) -> LoadablePickerModel<ID, Item> {
        
        return composeLoadablePickerModel(load: load, reload: load, makeID: makeID, prefix: prefix, suffix: suffix, placeholderCount: placeholderCount)
    }
    
    /// Composes a `LoadablePickerModel` using `UUID` as the identifier type.
    ///
    /// - Parameters:
    ///   - load: The closure to load items asynchronously.
    ///   - reload: The closure to reload items asynchronously.
    ///   - prefix: Static items to prepend before loaded items.
    ///   - suffix: Static items to append after loaded items.
    ///   - placeholderCount: The number of placeholder items to show during loading.
    /// - Returns: A `LoadablePickerModel` configured with the provided parameters.
    func composeLoadablePickerModel<Item>(
        load: @escaping (@escaping ([Item]?) -> Void) -> Void,
        reload: @escaping (@escaping ([Item]?) -> Void) -> Void,
        prefix: [LoadablePickerState<UUID, Item>.Item] = [],
        suffix: [LoadablePickerState<UUID, Item>.Item],
        placeholderCount: Int
    ) -> LoadablePickerModel<UUID, Item> {
        
        return composeLoadablePickerModel(load: load, reload: reload, makeID: UUID.init, prefix: prefix, suffix: suffix, placeholderCount: placeholderCount)
    }
    
    /// Composes a `LoadablePickerModel` using `UUID` as the identifier type and identical load/reload behavior.
    ///
    /// - Parameters:
    ///   - load: The closure to load or reload items asynchronously.
    ///   - prefix: Static items to prepend before loaded items.
    ///   - suffix: Static items to append after loaded items.
    ///   - placeholderCount: The number of placeholder items to show during loading.
    /// - Returns: A `LoadablePickerModel` configured with the provided parameters.
    func composeLoadablePickerModel<Item>(
        load: @escaping (@escaping ([Item]?) -> Void) -> Void,
        prefix: [LoadablePickerState<UUID, Item>.Item] = [],
        suffix: [LoadablePickerState<UUID, Item>.Item],
        placeholderCount: Int
    ) -> LoadablePickerModel<UUID, Item> {
        
        return composeLoadablePickerModel(load: load, reload: load, makeID: UUID.init, prefix: prefix, suffix: suffix, placeholderCount: placeholderCount)
    }
}
