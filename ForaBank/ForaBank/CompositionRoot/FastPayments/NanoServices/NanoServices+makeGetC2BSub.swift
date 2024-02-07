//
//  NanoServices+makeGetC2BSub.swift
//  ForaBank
//
//  Created by Igor Malyarov on 04.02.2024.
//

import FastPaymentsSettings

extension NanoServices {
    
    static func makeGetC2BSub(
        _ httpClient: HTTPClient,
        _ log: @escaping (String, StaticString, UInt) -> Void
    ) -> VoidFetch<GetC2BSubResponse, ServiceFailure> {
#warning("move to the call site")
        let fetch = adaptedLoggingFetch(
            createRequest: ForaRequestFactory.createGetC2BSubRequest,
            httpClient: httpClient,
            mapResponse: FastResponseMapper.mapGetC2BSubResponseResponse,
            mapError: ServiceFailure.init(error:),
            log: log
        )
        
        return { completion in
            
            fetch { completion($0.map(\.getC2BSubResponse)) }
        }
    }
}

#warning("remove mapping after changing return type of `static ResponseMapper.mapGetC2BSubResponseResponse(_:_:)` to `GetC2BSubResponse`")
// MARK: - Adapters

private extension GetC2BSubscription {
    
    var getC2BSubResponse: GetC2BSubResponse {
        
        .init(
            title: title,
            explanation: emptyList ?? [],
            details: {
                switch list {
                case .none:
                    return .empty
                case let .some(list):
                    return .list(list.map(\.getC2BProductSub))
                }
            }()
        )
    }
}

private extension GetC2BSubscription.ProductSubscription {
    
    var getC2BProductSub: GetC2BSubResponse.Details.ProductSubscription {
        
        .init(
            productID: productId,
            productType: {
                switch productType {
                case .account: return .account
                case .card: return .card
                }
            }(),
            productTitle: productTitle,
            subscriptions: subscription.map(\.sub)
        )
    }
}

private extension GetC2BSubscription.ProductSubscription.Subscription {
    
    var sub: GetC2BSubResponse.Details.ProductSubscription.Subscription {
 
        .init(
            subscriptionToken: subscriptionToken,
            brandIcon: brandIcon,
            brandName: brandName,
            subscriptionPurpose: subscriptionPurpose,
            cancelAlert: cancelAlert
        )
    }
}
