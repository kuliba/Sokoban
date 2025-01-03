//
//  FlowEffectHandler.swift
//
//
//  Created by Igor Malyarov on 23.08.2024.
//

import CombineSchedulers
import Foundation

public final class FlowEffectHandler<Select, Navigation> {
    
    private let getNavigation: GetNavigation
    
    @available(*, deprecated, message: "Control delays in `getNavigation`.")
    private let delay: Delay?
    
    @available(*, deprecated, message: "Control delay scheduling in `getNavigation`.")
    private let scheduler: AnySchedulerOf<DispatchQueue>?
    
    /// Creates a `FlowEffectHandler` with navigation closure.
    ///
    /// This designated initializer does not use an explicit `delay` or custom `scheduler`.
    /// Any timing, delay, or scheduling concerns should be handled directly in your `getNavigation`
    /// closure, ensuring you have full control over asynchronous logic without relying on global
    /// overrides.
    ///
    /// - Parameters:
    ///   - getNavigation: A closure that asynchronously maps a `Select` value
    ///     to a `Navigation` state. You can dispatch events or intermediate states via the `Notify`
    ///     callback, and provide the final `Navigation` state via the completion handler.
    ///
    /// - Warning: A delay is often needed to handle SwiftUI quirks (e.g., writing `nil` to a navigation
    ///   destination after a new destination is already set). The **best** practice is to incorporate such
    ///   delays within your `getNavigation` closure rather than using a fixed global delay.
    public init(
        getNavigation: @escaping GetNavigation
    ) {
        self.getNavigation = getNavigation
        self.delay = nil
        self.scheduler = nil
    }
    
    /// Creates a `FlowEffectHandler` with a fixed delay.
    ///
    /// This convenience initializer is deprecated in favor of the designated initializer
    /// `init(getNavigation:)`, allowing you to handle any delays or scheduling directly in
    /// `getNavigation` for maximum flexibility and clarity.
    ///
    /// - Parameters:
    ///   - delay: The delay used to handle SwiftUI quirks (e.g., writing `nil` to navigation destination).
    ///     This approach is deprecated; prefer handling delays in `getNavigation`.
    ///   - getNavigation: A closure that asynchronously maps a `Select` value to a `Navigation` state.
    ///   - scheduler: A scheduler for dispatching delayed actions. Defaults to a high-priority global queue.
    @available(*, deprecated, message: "Use the designated initializer `init(getNavigation:)` for more fine-grained control of delays and scheduling in `getNavigation`.")
    public init(
        delay: Delay = .milliseconds(100),
        getNavigation: @escaping GetNavigation,
        scheduler: AnySchedulerOf<DispatchQueue> = .global(qos: .userInteractive)
    ) {
        self.delay = delay
        self.getNavigation = getNavigation
        self.scheduler = scheduler
    }
}

public extension FlowEffectHandler {
    
    typealias Delay = DispatchQueue.SchedulerTimeType.Stride
    
    /// A typealias for the notify event sent during the navigation process.
    typealias NotifyEvent = FlowEvent<Select, Never>
    
    /// A typealias for the notify callback used to report intermediate events or progress.
    typealias Notify = (NotifyEvent) -> Void
    
    /// A typealias for the closure responsible for asynchronous navigation mapping.
    ///
    /// This callback-based function is triggered whenever a new `Select` event arrives.
    /// You can use `notify` to send intermediate states or progress updates, and call
    /// the `completion` handler to deliver the final `Navigation` outcome.
    ///
    /// - Parameters:
    ///   - select: The `Select` value triggering the navigation process.
    ///   - notify: A callback to send intermediate events or progress during the asynchronous operation.
    ///   - completion: A callback to deliver the final `Navigation` result upon successful processing.
    typealias GetNavigation = (Select, @escaping Notify, @escaping (Navigation) -> Void) -> Void
}

public extension FlowEffectHandler {
    
    func handleEffect(
        _ effect: Effect,
        _ dispatch: @escaping Dispatch
    ) {
        switch effect {
        case let .select(select):
            handle(select, dispatch)
        }
    }
}

public extension FlowEffectHandler {
    
    typealias Dispatch = (Event) -> Void
    
    typealias Event = FlowEvent<Select, Navigation>
    typealias Effect = FlowEffect<Select>
}

private extension FlowEffectHandler {
    
    func handle(
        _ select: Select,
        _ dispatch: @escaping Dispatch
    ) {
        let notify: Notify = { event in
            
            switch event {
            case .dismiss:
                dispatch(.dismiss)
                
            case let .isLoading(isLoading):
                dispatch(.isLoading(isLoading))
                
            case let .select(select):
                dispatch(.select(select))
            }
        }
        
        getNavigation(select, notify) { [weak self] navigation in
            
            guard let self else { return }
            
            guard let delay, let scheduler
            else { return dispatch(.navigation(navigation)) }
            
            scheduler.delay(for: delay) {
                
                dispatch(.navigation(navigation))
            }
        }
    }
}

private extension AnySchedulerOf<DispatchQueue> {
    
    func delay(
        for timeout: Delay,
        _ action: @escaping () -> Void
    ) {
        schedule(after: now.advanced(by: timeout), action)
    }
    
    typealias Delay = DispatchQueue.SchedulerTimeType.Stride
}
