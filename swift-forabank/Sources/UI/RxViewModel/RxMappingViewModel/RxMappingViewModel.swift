//
//  RxMappingViewModel.swift
//
//
//  Created by Igor Malyarov on 03.06.2024.
//

import Combine
import Foundation

/// A view model that maps a list of identifiable items to a list of models using a provided mapping function.
/// It observes changes from an observable view model and updates its state accordingly.
public final class RxMappingViewModel<ItemModel, Item, Event, Effect>: ObservableObject
where Item: Identifiable {
    
    @Published var state: [Item]
    
    private let map: Map
    private var _models: [Item.ID: ItemModel]
    
    private let observable: ObservableViewModel
    
    /// Initializes a new instance of `RxMappingViewModel`.
    ///
    /// - Parameters:
    ///   - observable: The observable view model that provides the initial state and state updates.
    ///   - map: The function that maps items of type `Item` to models of type `ItemModel`.
    ///   - scheduler: The scheduler on which to receive state updates. Defaults to the main queue.
    public init(
        observable: ObservableViewModel,
        map: @escaping Map,
        scheduler: AnySchedulerOfDispatchQueue = .makeMain()
    ) {
        self.state = observable.state
        self.observable = observable
        self.map = map
        self._models = .init(uniqueKeysWithValues: observable.state.map { ($0.id, map($0)) })
        
        observable.$state
            .dropFirst()
            .receive(on: scheduler)
            .assign(to: &$state)
    }
}

public extension RxMappingViewModel {
    
    /// The computed models derived from the current state using the mapping function.
    var models: [ItemModel] {
        
        state.map {
            
            if let tModel = _models[$0.id] {
                return tModel
            } else {
                let tModel = map($0)
                _models[$0.id] = tModel
                return tModel
            }
        }
    }
    
    /// Sends an event to the underlying observable view model.
    ///
    /// - Parameter event: The event to be sent to the observable view model.
    func event(_ event: Event) {
        
        observable.event(event)
    }
}

public extension RxMappingViewModel {
    
    /// A typealias representing an observable view model that provides a state, events, and effects.
    typealias ObservableViewModel = RxViewModel<[Item], Event, Effect>
    /// A typealias representing a mapping function that converts items of type `Item` to models of type `ItemModel`.
    typealias Map = (Item) -> ItemModel
}
