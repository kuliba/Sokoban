//
//  C2BSubscriptionEffectHandler+preview.swift
//  
//
//  Created by Igor Malyarov on 11.02.2024.
//

import Foundation

public extension C2BSubscriptionEffectHandler {
    
    static let preview = C2BSubscriptionEffectHandler(
        cancelSubscription: { subscription, completion in
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                
                completion(.success(.init()))
            }
        },
        getSubscriptionDetail: { subscription, completion in
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                
                completion(.success(.init()))
            }
        }
    )
}
