//
//  HandleEffectDecorator.swift
//
//
//  Created by Igor Malyarov on 18.05.2024.
//

/// A decorator class that handles side effects in an event-driven system.
/// It allows you to add additional behaviour before and after the main effect processing.
public final class HandleEffectDecorator<Event, Effect> {
    
    private let decoratee: Decoratee
    private let decoration: Decoration
    
    /// Initialises a new `HandleEffectDecorator` with the given decoratee and decoration.
    ///
    /// - Parameters:
    ///   - decoratee: The effect handler function to be decorated.
    ///   - decoration: The decoration actions to be performed before and after the effect handling.
    public init(
        decoratee: @escaping Decoratee,
        decoration: Decoration
    ) {
        self.decoratee = decoratee
        self.decoration = decoration
    }
}

public extension HandleEffectDecorator {
    
    /// Handles an effect by invoking the decorated effect handler and dispatching the resulting event.
    /// The decoration actions are performed before and after the effect handling.
    ///
    /// - Parameters:
    ///   - effect: The effect to be handled.
    ///   - dispatch: The function to be called with the resulting event.
    ///
    /// - Note: This method uses a weak reference to `self` to avoid retain cycles. If the decorator instance is deallocated before the decorated function completes, the completion handler will not be called.
    func handleEffect(
        _ effect: Effect,
        _ dispatch: @escaping Dispatch
    ) {
        decoratee(effect) { [weak self] event in
            
            guard let self else { return }
            
            decoration.onEffectStart()
            dispatch(event)
            decoration.onEffectFinish()
        }
    }
    
    /// Handles an effect by invoking the decorated effect handler and dispatching the resulting event.
    /// The decoration actions are performed before and after the effect handling.
    ///
    /// - Parameters:
    ///   - effect: The effect to be handled.
    ///   - dispatch: The function to be called with the resulting event.
    ///
    /// - Note: This method uses a strong reference to `self`, ensuring that the completion handler is called
    /// even if the decorator instance is deallocated before the decorated function completes.
    func callAsFunction(
        _ effect: Effect,
        _ dispatch: @escaping Dispatch
    ) {
        handleEffect(effect) { [self] in dispatch($0); _ = self }
    }
}

public extension HandleEffectDecorator {
    
    /// Type alias for the decorated effect handler function.
    typealias Decoratee = (Effect, @escaping Dispatch) -> Void
    /// Type alias for the dispatch function that handles events.
    typealias Dispatch = (Event) -> Void
}

extension HandleEffectDecorator {
    
    /// A structure to define decoration actions to be performed before and after the effect handling.
    public struct Decoration {
        
        /// Closure to be called before the effect handling starts.
        let onEffectStart: () -> Void
        /// Closure to be called after the effect handling finishes.
        let onEffectFinish: () -> Void
        
        public init(
            onEffectStart: @escaping () -> Void,
            onEffectFinish: @escaping () -> Void
        ) {
            self.onEffectStart = onEffectStart
            self.onEffectFinish = onEffectFinish
        }
    }
}
