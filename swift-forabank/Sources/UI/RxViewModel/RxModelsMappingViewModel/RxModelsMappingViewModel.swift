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
public final class RxModelsMappingViewModel<ItemModel, Item, Event, Effect>: ObservableObject
where Item: Identifiable {
    
    /// The current state of mapped item models.
    @Published public private(set) var state: [ItemModel]
    
    private let map: Map
    private var modelsCache: [Item.ID: ItemModel]
    
    private let observable: ObservableViewModel
    private var cancellables = Set<AnyCancellable>()
    
    /// Initializes a new instance of `RxModelsMappingViewModel`.
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
        let pairs = observable.state.map { ($0.id, map($0)) }
        self.state = pairs.map(\.1)
        self.observable = observable
        self.map = map
        self.modelsCache = .init(uniqueKeysWithValues: pairs)
        
        observable.$state
            .dropFirst()
            .receive(on: scheduler)
            .sink { [weak self] in self?.update(with: $0) }
            .store(in: &cancellables)
        
        print(">>>>>> \(self) init")
    }
    
    deinit {
        
        print(">>>>>> \(self) deinit")
    }
}

public extension RxModelsMappingViewModel {
    
    /// Sends an event to the underlying observable view model.
    ///
    /// - Parameter event: The event to be sent to the observable view model.
    func event(_ event: Event) {
        
        observable.event(event)
    }
}

public extension RxModelsMappingViewModel {
    
    /// A typealias representing an observable view model that provides a state, events, and effects.
    typealias ObservableViewModel = RxViewModel<[Item], Event, Effect>
    /// A typealias representing a mapping function that converts items of type `Item` to models of type `ItemModel`.
    typealias Map = (Item) -> ItemModel
}

private extension RxModelsMappingViewModel {
    
    /// Updates the state with new items.
    ///
    /// - Parameter items: The new items to update the state with.
    func update(with items: [Item]) {
        
        // TODO: remove unused models from `_models`
        
        state = items.map {
            
            if let model = modelsCache[$0.id] {
                return model
            } else {
                let model = map($0)
                modelsCache[$0.id] = model
                return model
            }
        }
    }
}
