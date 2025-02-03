//
//  ItemListEffectHandler.swift
//
//
//  Created by Igor Malyarov on 17.01.2025.
//

/// Handles loading and reloading effects for an ItemList.
/// Manages state transitions and event notifications during ItemList Loading and Item Processing.
public final class ItemListEffectHandler<Entity>
where Entity: Identifiable {
    
    /// Action to load the ItemList.
    public let load: Load
    
    /// Action to reload the ItemList.
    public let reload: Load
    
    /// Initializes the effect handler with load and reload actions.
    /// - Parameters:
    ///   - load: Closure to handle the initial loading of items.
    ///   - reload: Closure to handle reloading of items.
    public init(
        load: @escaping Load,
        reload: @escaping Load
    ) {
        self.load = load
        self.reload = reload
    }
}

public extension ItemListEffectHandler {
    
    /// Represents a single item with its load state.
    typealias Element = Stateful<Entity, LoadState>
    
    /// Completion handler for load actions.
    typealias LoadCompletion = ([Element]?) -> Void
    
    /// Defines the signature for load and reload actions.
    /// - Parameters:
    ///   - Notify: Dispatch closure to send events during loading.
    ///   - LoadCompletion: Closure called when loading completes.
    typealias Load = (@escaping Notify, @escaping LoadCompletion) -> Void
    
    /// Alias for dispatching events.
    typealias Notify = Dispatch
    
    /// Closure to dispatch an event.
    typealias Dispatch = (Event) -> Void
    
    /// Represents loading-related events for the ItemList.
    typealias Event = ItemListEvent<Entity>
    
    /// Represents loading-related effects for the ItemList.
    typealias Effect = ItemListEffect
}

public extension ItemListEffectHandler {
    
    /// Handles load and reload effects by executing the corresponding action and dispatching the result.
    /// - Parameters:
    ///   - effect: The effect to handle (`.load` or `.reload`).
    ///   - dispatch: Closure to dispatch the result event.
    func handleEffect(
        _ effect: Effect,
        _ dispatch: @escaping Dispatch
    ) {
        switch effect {
        case .load:
            load(dispatch) { [weak self] in
                
                guard self != nil else { return }
                
                dispatch(.loaded($0))
            }
            
        case .reload:
            reload(dispatch) { [weak self] in
                
                guard self != nil else { return }
                
                dispatch(.loaded($0))
            }
        }
    }
}

public extension ItemListEffectHandler {
    
    /// Convenience initializer for simplified load and reload setup without explicit dispatch.
    /// - Parameters:
    ///   - _load: Closure for loading items without event notifications.
    ///   - reload: Closure for reloading items without event notifications.
    convenience init(
        load: @escaping (@escaping LoadCompletion) -> Void,
        reload: @escaping (@escaping LoadCompletion) -> Void
    ) {
        self.init(
            load: { load($1) },
            reload: { reload($1) }
        )
    }
}
