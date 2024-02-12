//
//  C2BSubscriptionReducer.swift
//
//
//  Created by Igor Malyarov on 11.02.2024.
//

import TextFieldComponent

public final class C2BSubscriptionReducer {
    
    private let textFieldReducer: TextFieldReducer
    
    public init(
        textFieldReducer: TextFieldReducer = TransformingReducer(placeholderText: "Поиск")
    ) {
        self.textFieldReducer = textFieldReducer
    }
}

public extension C2BSubscriptionReducer {
    
    func reduce(
        _ state: State,
        _ event: Event
    ) -> (State, Effect?) {
        
        var state = state
        var effect: Effect?
        
        switch event {
        case let .alertTap(alertEvent):
            (state, effect) = reduce(state, alertEvent)
            
        case let .destination(destinationEvent):
            (state, effect) = reduce(state, destinationEvent)
            
        case let .subscription(subscriptionEvent):
            (state, effect) = reduce(state, subscriptionEvent)
            
        case let .subscriptionTap(tap):
            (state, effect) = reduce(state, tap)
            
        case let .textField(textFieldAction):
            (state, effect) = reduce(state, textFieldAction)
        }
        
        return (state, effect)
    }
}

public extension C2BSubscriptionReducer {
    
    typealias TextFieldReducer = TextFieldComponent.Reducer
    
    typealias State = C2BSubscriptionState
    typealias Event = C2BSubscriptionEvent
    typealias Effect = C2BSubscriptionEffect
}

private extension C2BSubscriptionReducer {
    
    func reduce(
        _ state: State,
        _ event: C2BSubscriptionEvent.AlertEvent
    ) -> (State, Effect?) {
        
        var state = state
        var effect: Effect?
        
        switch event {
        case .cancel:
            state.status = nil
            
        case let .delete(subscription):
            state.status = .inflight
            effect = .subscription(.delete(subscription))
        }
        
        return (state, effect)
    }
    
    func reduce(
        _ state: State,
        _ event: C2BSubscriptionEvent.DestinationEvent
    ) -> (State, Effect?) {
        
        var state = state
        
        switch event {
        case .dismiss:
            state.status = nil
        }
        
        return (state, nil)
    }
    
    func reduce(
        _ state: State,
        _ event: C2BSubscriptionEvent.SubscriptionEvent
    ) -> (State, Effect?) {
        
        var state = state
        
        switch event {
        case let .cancelled(confirmation):
            state.status = .cancelled(confirmation)

        case let .cancelFailure(failure):
            state.status = .failure(failure)

        case let .detailReceived(detail):
            state.status = .detail(detail)

        case let .detailFailure(failure):
            state.status = .failure(failure)
        }
        
        return (state, nil)
    }
    
    func reduce(
        _ state: State,
        _ tap: C2BSubscriptionEvent.SubscriptionTap
    ) -> (State, Effect?) {
        
        var state = state
        var effect: Effect?
        
        switch tap.event {
        case .delete:
            state.status = .tapAlert(.cancelSubscription(tap.subscription))
            
        case .detail:
            state.status = .inflight
            effect = .subscription(.getDetails(tap.subscription))
        }
        
        return (state, effect)
    }
    
    func reduce(
        _ state: State,
        _ textFieldAction: TextFieldAction
    ) -> (State, Effect?) {
        
        var state = state
        
        if let textFieldState = try? textFieldReducer.reduce(state.textFieldState, with: textFieldAction) {
            state.textFieldState = textFieldState
        }
        
        return (state, nil)
    }
}

private extension C2BSubscriptionState.TapAlert {
    
    static func cancelSubscription(
        _ subscription: C2BSubscriptionEvent.Subscription
    ) -> Self {
        
        .init(
            title: subscription.cancelAlert,
            message: nil,
            primaryButton: .init(
                type: .default,
                title: "Отключить",
                event: .delete(subscription)
            ),
            secondaryButton: .init(
                type: .cancel,
                title: "Отмена",
                event: .cancel
            )
        )
    }
}
