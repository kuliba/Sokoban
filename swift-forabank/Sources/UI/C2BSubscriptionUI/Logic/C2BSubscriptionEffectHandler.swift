//
//  C2BSubscriptionEffectHandler.swift
//
//
//  Created by Igor Malyarov on 11.02.2024.
//

public final class C2BSubscriptionEffectHandler {
    
    private let cancelSubscription: CancelSubscription
    private let getSubscriptionDetail: GetSubscriptionDetail
    
    public init(
        cancelSubscription: @escaping CancelSubscription,
        getSubscriptionDetail: @escaping GetSubscriptionDetail
    ) {
        self.cancelSubscription = cancelSubscription
        self.getSubscriptionDetail = getSubscriptionDetail
    }
}

public extension C2BSubscriptionEffectHandler {
    
    func handleEffect(
        _ effect: Effect,
        _ dispatch: @escaping Dispatch
    ) {
        switch effect {
        case let .delete(subscription):
            cancelSubscription(subscription) {
                
                switch $0 {
                case let .failure(failure):
                    dispatch(.cancelFailure(failure))
                
                case let .success(success):
                    dispatch(.cancelled(success))
                }
            }
            
        case let .getDetails(subscription):
            getSubscriptionDetail(subscription) {
                
                switch $0 {
                case let .failure(failure):
                    dispatch(.detailFailure(failure))
                
                case let .success(success):
                    dispatch(.detailReceived(success))
                }
            }
        }
    }
}

public extension C2BSubscriptionEffectHandler {
    
    typealias Subscription = GetC2BSubResponse.Details.ProductSubscription.Subscription
    
    typealias CancelSubscriptionResult = Result<CancelC2BSubscriptionConfirmation, ServiceFailure>
    typealias CancelSubscriptionCompletion = (CancelSubscriptionResult) -> Void
    typealias CancelSubscription = (Subscription, @escaping CancelSubscriptionCompletion) -> Void
    
    typealias GetSubscriptionDetailResult = Result<C2BSubscriptionDetail, ServiceFailure>
    typealias GetSubscriptionDetailCompletion = (GetSubscriptionDetailResult) -> Void
    typealias GetSubscriptionDetail = (Subscription, @escaping GetSubscriptionDetailCompletion) -> Void
    
    typealias Dispatch = (Event) -> Void
    
    typealias Event = C2BSubscriptionEvent.SubscriptionEvent
    typealias Effect = C2BSubscriptionEffect.SubscriptionEffect
}
